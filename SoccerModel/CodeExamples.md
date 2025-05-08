import pyspark

from pyspark.sql import SparkSession
spark =  SparkSession.builder.appName('testnet').getOrCreate() #create a spark session

filepath = r'C:\Users\hadyaleelanandam\Documents\PDS2024.csv' #filepath use r'' to set the file path <br>
df_spark = spark.read.csv(filepath) <br>
df_spark = spark.read.option('header','true').csv(filepath, inferSchema=True) #read csv file <br>
df_spark = spark.read.csv(filepath, header=True, inferSchema = True) #alternative way to read csv <br>
df = spark.read.format('csv').option('inferSchema', True).option('header', True).load(filepath)<br>


df_spark.show() # show dataframe <br>
df_spark.printSchema() #df information  <br>

#map lambda and map function <br>
list(map(lambda n: n**2, range(1,10,3))) <br>
list(filter(lambda n: n%2 != 0, nums ))  #filter nums = [1, 34, 23, 56, 89, 44, 92] <br>
list comprehension = [x for x in fruits if x != "apple"] <br>

df.withColumn('Margin', df['Hold'] / df['Turnover']) #create a column 
df.drop('SomeColumn') # drop column 
df.withColumnRenamed('name', 'New name') #rename 

# Databricks
PySpark  
Spark - Distributed computing engine using clusters, Master-Slave Architecture (driver program and worker nodes),<br> 
why use spark - it processes in-memory computation, lazy evaluation (transformation -> logical plan -> action)
