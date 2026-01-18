from sheets_manager import get_monthly_spreadsheet, set_exchange_rate, set_budget, get_monthly_summary
from datetime import datetime

def test_system():
    print("🚀 Iniciando prueba de Sistema Mensual...")
    
    # 1. Probar obtención/creación de hoja
    print("\n📄 1. Obteniendo Spreadsheet del mes actual...")
    try:
        ss = get_monthly_spreadsheet()
        print(f"✅ Spreadsheet obtenido: {ss.title}")
    except Exception as e:
        print(f"❌ Error obteniendo spreadsheet: {e}")
        return

    # 2. Probar Tasa
    print("\n💵 2. Configurando Tasa...")
    success, msg = set_exchange_rate(60.5, "PRUEBA_AUTO")
    if success:
        print("✅ Tasa guardada correctamente.")
    else:
        print(f"❌ Error guardando tasa: {msg}")

    # 3. Probar Presupuesto
    print("\n📊 3. Configurando Presupuesto...")
    if set_budget("Comida", 250.0):
        print("✅ Presupuesto 'Comida' guardado: 250.0")
    else:
        print("❌ Error guardando presupuesto.")

    # 4. Verificar Resumen (debe estar vacío o con lo que tenga)
    print("\n📈 4. Consultando Resumen...")
    summary = get_monthly_summary()
    if summary:
        print(f"✅ Resumen obtenido. Total USD: {summary['total_usd']}")
    else:
        print("❌ Error obteniendo resumen.")

if __name__ == "__main__":
    test_system()
