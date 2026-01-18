from sheets_manager import get_monthly_spreadsheet, set_exchange_rate
from datetime import datetime

def test_manual_monthly():
    now = datetime.now()
    expected_name = f"Gastos_{now.year}_{now.month:02d}"
    print(f"🚀 Probando Sistema Manual Mensual")
    print(f"📄 Buscando archivo: {expected_name}")
    
    try:
        ss = get_monthly_spreadsheet()
        print(f"✅ Archivo encontrado y abierto: {ss.title}")
        
        print("🔧 Configurando tasa de prueba...")
        success, msg = set_exchange_rate(61.0, "TEST_MANUAL", ss)
        if success:
            print("✅ Tasa configurada correctamente.")
        else:
            print(f"❌ Error configurando tasa: {msg}")
            
    except Exception as e:
        import traceback
        print(f"❌ Error durante la prueba:")
        traceback.print_exc()

if __name__ == "__main__":
    test_manual_monthly()
