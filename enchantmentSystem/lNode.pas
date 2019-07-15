implementation
type
    lnode = class(node)
    

private
    enchNode := bEnchNode;
    next := bEnchNode;
    down := lnode;
public
    constructor create(ilevel : integer, ienchNode : bEnchNode, inext : bEnchNode);
        level := ilevel;
        enchNode := ienchNode;
        next := inext;
    end;
//getters
    function getnode()bEnchNode;
    begin
        result := enchNode;
    end;
    function getlevel()integer;
    begin
        result := level;
    end;
    function getprevous()lnode;
    begin
        result := prevous;
    end;