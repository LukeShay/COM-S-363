// Item 1
db.getCollection("Person").find({},{Name: 1, Address: 1, _id: 0})

// Item 2
db.getCollection("Person").aggregate(
    [
        { 
            "$lookup" : {
                "from" : "Student", 
                "localField" : "ID", 
                "foreignField" : "StudentID", 
                "as" : "info"
            }
        }, 
        { 
            "$out" : "item_2"
        }
    ], 
    { 
        "allowDiskUse" : false
    }
)

db.getCollection("item_2").find({info:  {$size: 1}}, {Name: 1, _id: 0})

//Item 3
db.getCollection("item_2").aggregate(
    [
        { 
            "$lookup" : {
                "from" : "Person", 
                "localField" : "ID", 
                "foreignField" : "info: [0: {MentorID}]", 
                "as" : "MentorInfo"
            }
        }
    ], 
    { 
        "allowDiskUse" : false
    }
);