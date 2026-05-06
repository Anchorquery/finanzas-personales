export default ({ filter, action }, { services, exceptions }) => {
	const { ItemsService } = services;
	const { InvalidPayloadException } = exceptions;

	filter('workspaces.items.create', async (payload, meta, context) => {
		return await validateWorkspaceMembers(payload, meta, context, false);
	});

	filter('workspaces.items.update', async (payload, meta, context) => {
		return await validateWorkspaceMembers(payload, meta, context, true);
	});

	async function validateWorkspaceMembers(payload, meta, context, isUpdate) {
		if (payload.access_member_ids === undefined) return payload;

		let memberIds = payload.access_member_ids;
		if (!Array.isArray(memberIds)) {
			try {
				if (typeof memberIds === 'string') memberIds = JSON.parse(memberIds);
				else memberIds = [];
			} catch (e) {
				memberIds = [];
			}
		}

		// "limpiar ids duplicados"
		memberIds = [...new Set(memberIds)];

		let orgId = payload.organization;
		let ownerId = payload.user;

		if (isUpdate && meta.keys?.length > 0) {
			const workspacesService = new ItemsService('workspaces', {
				schema: context.schema,
				accountability: context.accountability, // use context accountability which corresponds to the request auth context
			});
            
            // Allow system override without full context tracking if necessary, 
            // but the request is authenticated anyway
			const workspace = await workspacesService.readOne(meta.keys[0], { fields: ['organization', 'user'] });
			if (!orgId) orgId = workspace?.organization;
			if (!ownerId) ownerId = workspace?.user;
		}

		// "impedir quitar acceso al owner"
        // Si el owner estaba implícitamente protegido por ser "user", el access_member_ids no define a owner.
        // Pero si nos lo piden, vamos a asegurar que si ownerId tiene un valor, y es una operación sobre restricted, 
        // tal vez requiera estar añadido siempre:
        if (ownerId && !memberIds.includes(ownerId)) {
            memberIds.push(ownerId);
        }

        // "impedir guardar access_member_ids con usuarios que no pertenecen a la organización del workspace"
		if (orgId && memberIds.length > 0) {
			const membersService = new ItemsService('organization_members', {
				schema: context.schema,
				accountability: context.accountability,
			});
            
			const validMembers = await membersService.readByQuery({
				filter: {
					organization: { _eq: orgId },
					user: { _in: memberIds },
				},
				limit: -1,
			});
            
			const validUserIds = validMembers.map((m) => m.user);
			const invalidIds = memberIds.filter((id) => !validUserIds.includes(id));
            
			if (invalidIds.length > 0) {
				throw new InvalidPayloadException(
					`Members array contains users that are not in the organization: ${invalidIds.join(', ')}`
				);
			}
		}
        
        payload.access_member_ids = memberIds;
		return payload;
	}
};
