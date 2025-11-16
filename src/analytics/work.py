# %%
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt


engine = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

def import_query(path):
    with open(path) as open_file:
        return open_file.read()
    
query = import_query("teste.sql")

# %%
df = pd.read_sql(query, engine)

df = df[df['dtRef'] > '2025-01-01']

for nome, grupo in df.groupby('descLifeCycle'):
    plt.plot(grupo['dtRef'], grupo['qtdeClientes'], marker='o', label=nome)

plt.title('Evolução de Clientes por Ciclo de Vida')
plt.xlabel('Data de Referência')
plt.ylabel('Quantidade de Clientes')
plt.legend()