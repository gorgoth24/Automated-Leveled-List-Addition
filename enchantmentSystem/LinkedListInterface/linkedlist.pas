interface
type
    linkedlist = Class;
    protected
        head, tail : node;
    public
        //getter and setters
        function gethead()node;
            result := head;
        end;
        
        function gettail()node;
            result := tail;
        end;
        
        procedure addnode(inode : node);//unsorted
            tail.addnode(inode)
        end;
        