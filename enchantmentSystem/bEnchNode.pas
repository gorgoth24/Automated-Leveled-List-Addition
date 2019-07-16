implementation

type
    bEnchNode = class(node)

private
    levels : levellist;
    childEnchs : cEnchLinkedList; 
    FormId : cardinal;
        
public
    constructor create(iFormId : cardinal, inode : lnode);
    begin
        FormId := iFormId;
        levels := levellist.create(self, inode);
    end;
    
    
//child enchantments
    procedure addchild(iNode : cEnchNode);
    begin
        if childEnchs = nil then
            childEnchs := cEnchLinkedList.create(inode);
        end else childEnchs.insertnode(inode)
        end;
    end;
    
//getters
     function getFormId()cardinal;
     begin
        result := FormId;
     end;
     function getlevels()levellist;
     begin
        result := levels;
     end;