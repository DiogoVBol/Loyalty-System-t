
import argparse
import pandas as pd
import sqlalchemy
import datetime

# Função para abrir o arquivo SQL e ler o código
def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

def date_range(start, stop):
    dates = []

    while start <= stop:
        dates.append(start)
        dt_start = datetime.datetime.strptime(start, '%Y-%m-%d') + datetime.timedelta(days=1)
        start = datetime.datetime.strftime(dt_start, '%Y-%m-%d')
    return dates

def exec_query(table, db_origin, db_target, dt_start, dt_stop):

    query = import_query(f"{table}.sql")

    # Definir a engine é o mesmo que criar uma conexão com o db
    engine_app = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")

    engine_analytical = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")

    dates = date_range(dt_start,dt_stop)

    for i in dates:

        with engine_analytical.connect() as con:

            try:
                query_delete = f"DELETE FROM {table} WHERE dtRef = date('{i}','-1 day')"
                con.execute(sqlalchemy.text(query_delete))
                con.commit()
            except Exception as err:
                print(err)

        print(i)
        query_format = query.format(date=i)

        df = pd.read_sql(query_format, engine_app)
        df.to_sql(table, engine_analytical, index=False, if_exists='append')

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('--db_origin',choices=['loyalty-system', 'education-platform', 'analytics'], default='loyalty-system')
    parser.add_argument('--db_target', choices= ['analytics'],default='loyalty-system')

    parser.add_argument('--table', type=str, help='Tabela que será processada com o mesmo nome do arquivo')
    parser.add_argument('--start',type=str,default='2024-03-01')
    
    stop = datetime.datetime.now().strftime('%Y-%m-%d')
    parser.add_argument('--stop',type=str,default=stop)

    args = parser.parse_args()

    exec_query(args.table, args.db_origin, args.db_target, args.start, args.stop)

if __name__ == '__main__':
    main()