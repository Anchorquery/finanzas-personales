import matplotlib.pyplot as plt
import io
import pandas as pd
from datetime import datetime

def generate_pie_chart(category_data: dict):
    if not category_data: return None
    
    plt.figure(figsize=(10, 6))
    plt.pie(category_data.values(), labels=category_data.keys(), autopct='%1.1f%%', startangle=140)
    plt.title("Gastos por Categoría (USD)")
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()
    return buf

def generate_comparison_chart(total_expenses: float, total_income: float):
    plt.figure(figsize=(8, 6))
    labels = ['Gastos', 'Ingresos']
    values = [total_expenses, total_income]
    colors = ['#ff9999', '#66b3ff']
    
    plt.bar(labels, values, color=colors)
    plt.title("Comparativa Mensual (USD)")
    plt.ylabel("Monto ($)")
    
    for i, v in enumerate(values):
        plt.text(i, v + (max(values)*0.01), f"${v:,.2f}", ha='center', fontweight='bold')
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()
    return buf

def generate_daily_trend(transactions: list):
    """Espera lista de dicts con 'Fecha' y 'Monto USD'"""
    if not transactions: return None
    
    df = pd.DataFrame(transactions)
    df['Fecha'] = pd.to_datetime(df['Fecha'])
    daily = df.groupby('Fecha')['Monto USD'].sum().reset_index()
    daily = daily.sort_values('Fecha')
    
    plt.figure(figsize=(10, 5))
    plt.plot(daily['Fecha'], daily['Monto USD'], marker='o', linestyle='-', color='orange')
    plt.fill_between(daily['Fecha'], daily['Monto USD'], color='orange', alpha=0.1)
    plt.title("Tendencia de Gastos Diarios")
    plt.xlabel("Día")
    plt.ylabel("USD")
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.xticks(rotation=45)
    
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()
    return buf

def generate_top5_expenses(transactions: list):
    """Top 5 gastos más altos del mes."""
    if not transactions or len(transactions) < 1: return None
    
    df = pd.DataFrame(transactions)
    # Asegurar que Monto USD sea numérico
    df['Monto USD'] = pd.to_numeric(df['Monto USD'].astype(str).str.replace(',', '.'), errors='coerce')
    df = df.dropna(subset=['Monto USD'])
    
    top5 = df.nlargest(5, 'Monto USD')
    
    if top5.empty: return None
    
    plt.figure(figsize=(10, 5))
    colors = ['#e74c3c', '#e67e22', '#f1c40f', '#3498db', '#9b59b6']
    bars = plt.barh(top5['Concepto'].astype(str).str[:20], top5['Monto USD'], color=colors[:len(top5)])
    plt.xlabel('USD')
    plt.title('💸 Top 5 Gastos Más Altos')
    plt.gca().invert_yaxis()
    
    for bar, val in zip(bars, top5['Monto USD']):
        plt.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height()/2, f'${val:,.2f}', va='center')
    
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()
    return buf

def generate_weekday_distribution(transactions: list):
    """Distribución de gastos por día de la semana."""
    if not transactions: return None
    
    df = pd.DataFrame(transactions)
    df['Fecha'] = pd.to_datetime(df['Fecha'], errors='coerce')
    df['Monto USD'] = pd.to_numeric(df['Monto USD'].astype(str).str.replace(',', '.'), errors='coerce')
    df = df.dropna(subset=['Fecha', 'Monto USD'])
    
    if df.empty: return None
    
    df['DiaSemana'] = df['Fecha'].dt.day_name()
    order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    spanish = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']
    
    by_day = df.groupby('DiaSemana')['Monto USD'].sum().reindex(order).fillna(0)
    
    plt.figure(figsize=(10, 5))
    colors = ['#3498db'] * 5 + ['#e74c3c', '#e74c3c']  # Fin de semana en rojo
    plt.bar(spanish, by_day.values, color=colors)
    plt.title('📅 Gastos por Día de la Semana')
    plt.ylabel('USD')
    plt.xticks(rotation=45)
    
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()
    return buf

def generate_monthly_comparison(current_month: dict, previous_month: dict):
    """Compara gastos e ingresos entre dos meses."""
    if not current_month or not previous_month:
        return None
    
    labels = ['Gastos', 'Ingresos']
    current_vals = [current_month.get('total_usd', 0), current_month.get('total_ingresos', 0)]
    previous_vals = [previous_month.get('total_usd', 0), previous_month.get('total_ingresos', 0)]
    
    x = range(len(labels))
    width = 0.35
    
    fig, ax = plt.subplots(figsize=(10, 6))
    bars1 = ax.bar([i - width/2 for i in x], previous_vals, width, label='Mes Anterior', color='#95a5a6')
    bars2 = ax.bar([i + width/2 for i in x], current_vals, width, label='Este Mes', color='#3498db')
    
    ax.set_ylabel('USD')
    ax.set_title('📊 Comparativa: Este Mes vs Anterior')
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()
    
    # Añadir valores sobre las barras
    for bar in bars1 + bars2:
        height = bar.get_height()
        ax.annotate(f'${height:,.0f}',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom', fontsize=10)
    
    # Calcular diferencias porcentuales
    diff_gastos = ((current_vals[0] - previous_vals[0]) / previous_vals[0] * 100) if previous_vals[0] > 0 else 0
    diff_ingresos = ((current_vals[1] - previous_vals[1]) / previous_vals[1] * 100) if previous_vals[1] > 0 else 0
    
    emoji_g = "📈" if diff_gastos > 0 else "📉"
    emoji_i = "📈" if diff_ingresos > 0 else "📉"
    
    ax.text(0.02, 0.98, f"{emoji_g} Gastos: {diff_gastos:+.1f}%\n{emoji_i} Ingresos: {diff_ingresos:+.1f}%",
            transform=ax.transAxes, fontsize=11, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()
    return buf
