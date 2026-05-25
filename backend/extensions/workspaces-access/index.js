export default ({ filter }, { services }) => {
	const { ItemsService } = services;

	// v11: exceptions removed from context — use custom error class
	class InvalidPayloadException extends Error {
		constructor(message) {
			super(message);
			this.status = 400;
			this.code = 'INVALID_PAYLOAD';
		}
	}

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

		memberIds = [...new Set(memberIds)];

		let orgId = payload.organization;
		let ownerId = payload.user;

		if (isUpdate && meta.keys?.length > 0) {
			const workspacesService = new ItemsService('workspaces', {
				schema: context.schema,
				accountability: context.accountability,
			});
			const workspace = await workspacesService.readOne(meta.keys[0], { fields: ['organization', 'user'] });
			if (!orgId) orgId = workspace?.organization;
			if (!ownerId) ownerId = workspace?.user;
		}

		if (ownerId && !memberIds.includes(ownerId)) {
			memberIds.push(ownerId);
		}

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
