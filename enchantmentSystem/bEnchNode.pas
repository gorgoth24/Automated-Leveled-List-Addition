implementation

type
    EnchNode = class(node)
private
    levels, childEnchs : leveledlist;
    FormId : cardinal;
public

    function getnext(level : integer)Enchnode;
    var
        i : integer;
        levelnode : node;
    begin
        levelnode := levels.gethead();
        for i := 1 to level do 
            levelnode := levelnode.getnext();
        end;
        result := levelnode.getnode();
    end;
    
    procedure addlevel(level: integer, inode : Enchnode)
    var
        i : integer;
    begin
        for i := 1 to level do
            
    end;
    
    
    