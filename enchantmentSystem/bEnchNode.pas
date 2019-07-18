implementation

type
    bEnchNode = class(node)

private
    levels : levellist;
    childEnchs : cEnchLinkedList; 
    FormId : cardinal;
    Ench : IInterface;
        
public
    constructor create(iFormId : cardinal, iEnch : IInterface);
    begin
        FormId := iFormId;
        Ench := iEnch;
        levels := levellist.create(self);
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
     function getEnch()IInterface;
     begin
        result := Ench;
     end;