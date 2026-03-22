我在使用SQLServer数据库，现在我要创建一个数据仓库的演示脚本，其中包括：

## OLTP层
### 数据库名：OLShop
包含如下表：
Customer: CustomerID, CustomerName, CustomerBirth, CustomerAddr
Product: ProductID, ProductName, ProductCode
Sales: SalesID, SalesNumber, CustomerID, ProductID, SalesAmount

## DWH层
以下为数据仓库的各个数据库。
其中每个数据库中的表都要包含：
LOAD_DTS, Datatime类型，记录数据加载的日期和时间。
LOAD_END_DTS, Datatime类型，如果是新记录，则其为NULL，如果是被更新的记录，则将历史的那条记录写成当前的日期时间，新记录记为NULL。
RECORD_SOURCE，记录数据的来源，这里使用OLTP的数据库名。
HK，由KEY列生成的Hash Key。
HASH_DIFF，对所有业务属性生成的哈希值。供增量逻辑的对比用。

### STAGE数据库：
数据库名：STAGE
包含从OLShop端一对一加载过来的数据，数据为全量加载，每次先TRUNCATE然后再INSERT，这部分的数据加载用存储过程实现，存储过程保留在此数据库。
其中每张表都要包含如下附加字段：


### DATA VAULT数据库：
数据库名：DV
包含从STAGE层加载到DATA VAULT层的数据，数据为全量加载，每次先TRUNCATE然后再INSERT。数据根据其不同的类型，分别加载到对应的SAT，HUB和LINK表里。这部分的数据加载用存储过程实现，存储过程保留在此数据库。

### STAR SCHEMA层：
数据库名：STAR
包含从DV层加载到STAR数据库的数据，这一层数据按照事实表和维度表的方式来组织，数据为全量加载，每次先TRUNCATE然后再INSERT。这部分的数据加载用存储过程实现，存储过程保留在此数据库。

### DATA MART层：
数据库名：DM
包含从STAR数据库到DM数据的加载，此层根据STAR层的数据将数据组织成宽表。数据为全量加载，每次先TRUNCATE然后再INSERT。这部分的数据加载用存储过程实现，存储过程保留在此数据库。


以上各个数据库，每个数据库保存到单独的文件夹中，每个文件夹都要包含：创建数据库的脚本，创建表的脚本，创建相应存储过程的脚本。其中OLTP的数据库，每个表都要插入一些测试数据。
