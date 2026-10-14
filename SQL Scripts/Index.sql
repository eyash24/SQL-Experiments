-- Indexes
/*
- data structure that provides quick access to data optimizing speed of query

Index Type
1. Structure
	1. Clustered Index
	2. Non-clustered index
2. Storage
	1. Rowstore index
	2. Columnstore index
3. Functions
	1. Unique index
	2. Filtered index

Pages
- smallest unit of data storage in a database (8kb)
- stored anything (data, metadata, index...)
Types 
	1. Data Page
	2. Index Page

Data Page
Header : File Id: Page Number
	row	...

Offset : where each row begins 

Default Stucture of storing data in databases -> Heap structure 
- tables w/o any clustered index
- Fast Write, Slow Read
- full scan done to read a particular value 

Clustered Index
- reorganises data into a B-tree 
- B-Tree or balanced tree -> hierarchical structure storing data at leaves to help quickly locate data 

B-Tree 
root node -> intermediate nodes -> leaf node
data stored at leaf nodes

Index Page
- stores key value (Pointers) to another page.
- doesnt store actual rows

Non clustered Index
- wont reorganise or change anything on the data page
- Index page stores a RID for each ID
- RID : FileID, Page Number, Offset
- create a B-tree of Index pages where the leaf nodes are index pages consisting of RID for ID

Note
- multiple non clustered index allowed but only 1 clustered index allowed 



	


*/