import pandas as pd
import sqlite3
import os

# ⚙️ CONFIGURACIÓN INICIAL
EXCEL_FILE = '04_Ventas_Datos_Limpios_S03.xlsx'
DATABASE_FILE = 'Novamarket_S07_joseluis.db'

def cargar_y_modelar():
    print(f"Iniciando carga desde: {EXCEL_FILE}...")
    
    try:
        # 1. LEER LOS DATOS (Limpios de Sesión 3)
        # Cargamos la tabla plana que preparaste en Power Query (Hoja: Tabla1)
        df = pd.read_excel(EXCEL_FILE, sheet_name='Tabla1')
        
        # 2. CONSTRUIR DIMENSIONES (NORMALIZACIÓN)
        # Separamos los 4 productos únicos para el diccionario
        print("🔨 Creando Diccionario de Productos...")
        dim_producto = df[['Producto', 'Categoria', 'Precio_Unitario', 'Costo_Unitario']].drop_duplicates().sort_values('Categoria').groupby('Producto').first().reset_index()
        dim_producto.insert(0, 'ProductoID', range(1, len(dim_producto) + 1))
        
        # Separamos las 6 ciudades únicas para el diccionario
        print("Creando Diccionario de Ciudades...")
        dim_ciudad = df[['Ciudad']].drop_duplicates().reset_index(drop=True)
        dim_ciudad.insert(0, 'CiudadID', range(1, len(dim_ciudad) + 1))
        
        # Agregamos la región (Ejemplo de mapeo rápido en Python)
        regiones = {
            'Bogota': 'Centro', 'Medellin': 'Andina', 'Cali': 'Pacifico',
            'Barranquilla': 'Caribe', 'Cartagena': 'Caribe', 'Leticia': 'Amazonia',
            'Bogotá': 'Centro', 'Medellín': 'Andina' # Por si acaso hay tildes
        }
        dim_ciudad['Region'] = dim_ciudad['Ciudad'].map(regiones).fillna('Otro')
        
        # Construimos el diccionario de fechas
        print("🔨 Creando Diccionario de Fechas...")
        fechas_unicas = pd.to_datetime(df['Fecha']).dt.normalize().unique()
        dim_fecha = pd.DataFrame({'Fecha': fechas_unicas})
        dim_fecha['FechaID'] = dim_fecha['Fecha'].dt.strftime('%Y%m%d').astype(int)
        
        meses_es = {1:'Enero', 2:'Febrero', 3:'Marzo', 4:'Abril', 5:'Mayo', 6:'Junio', 
                    7:'Julio', 8:'Agosto', 9:'Septiembre', 10:'Octubre', 11:'Noviembre', 12:'Diciembre'}
        dim_fecha['NombreMes'] = dim_fecha['Fecha'].dt.month.map(meses_es)
        
        dim_fecha['Evento_Especial'] = None
        dim_fecha.loc[dim_fecha['Fecha'] == '2023-11-24', 'Evento_Especial'] = 'Black Friday'
        
        dim_fecha['Fecha'] = dim_fecha['Fecha'].dt.strftime('%Y-%m-%d')
        dim_fecha = dim_fecha[['FechaID', 'Fecha', 'NombreMes', 'Evento_Especial']]
        
        # 3. CREAR TABLA DE HECHOS (FACTVENTAS)
        # Unimos todo usando IDs para que la base de datos sea eficiente
        print("Realizando el modelado final...")
        fact_ventas = df.copy()
        
        # Mapeamos los IDs de forma segura (buscando por nombre)
        fact_ventas = fact_ventas.merge(dim_producto[['Producto', 'ProductoID']], on='Producto', how='left')
        fact_ventas = fact_ventas.merge(dim_ciudad[['Ciudad', 'CiudadID']], on='Ciudad', how='left')
        
        # Formato de FechaID
        fact_ventas['FechaID'] = pd.to_datetime(fact_ventas['Fecha']).dt.strftime('%Y%m%d').astype(int)
        
        # Seleccionar columnas finales
        fact_ventas = fact_ventas[[
            'ID_Transaccion', 'FechaID', 'ProductoID', 'CiudadID', 
            'Cantidad', 'Precio_Unitario', 'Costo_Unitario', 'Descuento_pct', 'Costo_Envio'
        ]].rename(columns={'ID_Transaccion': 'TransaccionID', 'Precio_Unitario': 'Precio_Venta', 'Descuento_pct': 'Descuento_Pct'})

        # 4. GUARDAR EN LA BASE DE DATOS SQLITE
        conn = sqlite3.connect(DATABASE_FILE)
        dim_producto.to_sql('DimProducto', conn, if_exists='replace', index=False)
        dim_ciudad.to_sql('DimCiudad',     conn, if_exists='replace', index=False)
        dim_fecha.to_sql('DimFecha',       conn, if_exists='replace', index=False)
        fact_ventas.to_sql('FactVentas',   conn, if_exists='replace', index=False)
        
        print(f"✅ ¡Éxito! Base de Datos '{DATABASE_FILE}' creada.")
        print(f"📊 Resumen: Sales: {len(fact_ventas)} | Ciudades: {len(dim_ciudad)} | Productos: {len(dim_producto)} | Fechas: {len(dim_fecha)}")
        conn.close()
        
    except Exception as e:
        print(f"Error durante la carga: {e}")

if __name__ == "__main__":
    if os.path.exists(EXCEL_FILE):
        cargar_y_modelar()
    else:
        print(f"❌ No se encontró el archivo: {EXCEL_FILE}")
