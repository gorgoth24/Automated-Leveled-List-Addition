implementation
type
    lnode = class(node)
    

private
    enchNode := bEnchNode;
    next := lnode;
    down := lnode;
public
    constructor create(ienchNode : bEnchNode);
        enchNode := ienchNode;
    end;
//setters
    procedure setdown(inode : lnode);
    begin
        down := inode;
    end;
    procedure setnext(inode : lnode);
    begin
        next := lnode;
    end;
//getters
    function getnode()bEnchNode;
    begin
        result := enchNode;
    end;
    function getdown()lnode;
    begin
        result := down;
    end;
    function getnext()lnode;
    begin
        result := next;
    end;