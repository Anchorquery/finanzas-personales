from sheets_manager import get_master_spreadsheet, get_month_sheets, set_exchange_rate, set_budget, get_monthly_summary
from datetime import datetime

def test_tabs_system():
    print("🚀 Probando Sistema de Pestañas Mensuales...")
    
    try:
        # 1. Obtener Master
        ss = get_master_spreadsheet()
        print(f"✅ Master encontrado: {ss.title}")
        
        # 2. Inicializar mes actual (ej. G_2026_01)
        now = datetime.now()
        ws_g, ws_i, ws_p = get_month_sheets(now.year, now.month)
        print(f"✅ Pestañas obtenidas/creadas: {ws_g.title}, {ws_i.title}, {ws_p.title}")
        
        # 3. Tasa
        if set_exchange_rate(60.8, "TEST_TABS")[0]:
            print("✅ Tasa configurada.")
            
        # 4. Presupuesto
        if set_budget("Comida", 300):
            print("✅ Presupuesto Comida=300 configurado.")
            
        # 5. Summary
        summ = get_monthly_summary()
        print(f"✅ Resumen leido: Total {summ['total_usd']}")
        
    except Exception as e:
        print(f"❌ Error fatal: {e}")

if __name__ == "__main__":
    test_tabs_system()
