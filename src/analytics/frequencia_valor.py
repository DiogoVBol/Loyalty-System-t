# %%

import pandas as pd
import sqlalchemy
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn import cluster

# %%

engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

# %%

def import_query(path):
    with open(path) as open_file:
        return open_file.read()
    
query = import_query("frequencia_valor.sql")

# %%

df = pd.read_sql(query, engine)

df = df[df['QtdePontos']<4000]

# %%

plt.plot(df['QtdFrequencia'], df['QtdePontos'], 'o')
plt.grid()
plt.xlabel('Frequencia')
plt.ylabel('Valor')


# %%

from sklearn import preprocessing

mimmax = preprocessing.MinMaxScaler()

X = mimmax.fit_transform(df[['QtdFrequencia','QtdePontos']])

kmeans = cluster.KMeans(n_clusters=5, random_state=42, max_iter= 1000)

kmeans.fit(X)

df['cluster_calc'] = kmeans.labels_


# %%

df.groupby(by='cluster_calc')['idCliente'].count()

# %%

sns.scatterplot(data=df,
                x = 'QtdFrequencia',
                y = 'QtdePontos',
                hue = 'cluster_calc',
                palette='deep')

plt.hlines(y=1500,xmin=0, xmax=30, colors='black')
plt.hlines(y=750,xmin=0, xmax=30, colors='black')
plt.vlines(x=4,ymin=0,ymax=750)
plt.vlines(x=10,ymin=0,ymax=3000)

# %%

sns.scatterplot(data=df,
                x = 'QtdFrequencia',
                y = 'QtdePontos',
                hue = 'Cluster',
                palette='deep')

plt.hlines(y=1500,xmin=0, xmax=30, colors='black')
plt.hlines(y=750,xmin=0, xmax=30, colors='black')
plt.vlines(x=4,ymin=0,ymax=750)
plt.vlines(x=10,ymin=0,ymax=3000)



# %%

