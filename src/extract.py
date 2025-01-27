from typing import Dict

import requests
from pandas import DataFrame, read_csv, read_json, to_datetime
from pathlib import Path 
from io import StringIO 
import os

def get_public_holidays(public_holidays_url: str, year: str) -> DataFrame:
    url = f"{public_holidays_url}/{year}/BR"
    
    response = requests.get(url)
    
    response.raise_for_status() 
    
    df = read_json(StringIO(response.text))
    df = df.drop(columns=["types", "counties"]) 
    df["date"] = to_datetime(df["date"]) 
    
    return df

def extract(
    csv_folder: str = None,
    csv_table_mapping: Dict[str, str] = None,
    public_holidays_url: str = "https://date.nager.at/api/v3/PublicHolidays",
    year: str = "2017"
) -> Dict[str, DataFrame]:

    
    #calcular automcaticamernte la ruta si no se proporciona la carpeta
    if csv_folder is None:
        script_dir = Path(__file__).parent.absolute()  #Ruta del script (src/)
        project_root = script_dir.parent   # Raíz del proyecto (../)             
        csv_folder = project_root / "dataset"  # Ruta absoluta a dataset/        
    
    if not os.path.exists(csv_folder):
        raise FileNotFoundError(f"Carpeta no encontrada: {csv_folder}") #Lanzar un eror si la carpeta no existe
    
    if csv_table_mapping is None:
        csv_files = [f for f in os.listdir(csv_folder) if f.endswith(".csv")] #Verifica que hayan csv validos
        if not csv_files:
            raise ValueError(f"No hay archivos CSV en {csv_folder}")
        
        csv_table_mapping = {
            csv_file: csv_file.replace("olist_", "").replace("_dataset.csv", "")
            for csv_file in csv_files
        }
        
    dataframes = {
        table_name: read_csv(f"{csv_folder}/{csv_file}")
        for csv_file, table_name in csv_table_mapping.items()
    }
    
    holidays = get_public_holidays(public_holidays_url, year)
    dataframes["public_holidays"] = holidays
    
    return dataframes

data = extract()