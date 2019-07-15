implementation

type
    bEnchNode = class(node)

private
    levels : leveledlist;
    childEnchs : cEnchLinkedList; 
    FormId : cardinal;
    function coinflip()boolean;//used in determining height
    begin
        if 
            (randomrange(1, 2) = 1) then := true //tails
        end else 
            result := false //heads
        end;
    end;

        
public
    constructor create(iFormId : cardinal)
    var
        ilnode : lnode;
        i : int;
    begin
        FormId := iFormId;
        levels := levels.create();
        while coinflip() do
            i := i + 1;
            levels.addlevel(ilnode.create(i, iFormId))
        end;
    end;
    
    function levels.getnext(level : integer)Enchnode;
    begin
        levels.getnext(level);
    end;
    
    procedure addlevel(level: integer, inode : Enchnode)
    begin
        if levels = nil then
      
        end else
        levels.addlevel(level, inode)
        end;
    end;
    
//child enchantments
    procedure addchild(iNode : cEnchNode);
    begin
        if childEnchs = nil then
            
        end else childEnchs.insertnode(inode)
        end;
    end;
    

//data getter
     function getFormId()cardinal;
     begin
        result := FormId;
     end;