import os
import sys
from typing import Dict

from pandas import DataFrame
from sqlalchemy.engine.base import Engine
from sqlalchemy import create_engine
from extract import data 

root_directory = os.path.dirname(os.path.abspath(__file__))  
root_directory = os.path.dirname(root_directory)  
sys.path.insert(0, root_directory)

def load(data_frames: Dict[str, DataFrame], database: Engine):
    print("Cargando datos en la base de datos...")
    try:
        for table_name, df in data_frames.items():
            df.to_sql(
                name=table_name,          
                con=database,             
                if_exists="replace",      
                index=False               
            )
        print("¡Datos cargados exitosamente!")
    except Exception as e:
        print(f"Error al cargar datos: {e}")
        raise

database_path = os.path.join(root_directory, "latam-ecommerce.db")
database_uri = f"sqlite:///{database_path}"
engine = create_engine(database_uri)

extract_data = data  
load(extract_data, engine) 