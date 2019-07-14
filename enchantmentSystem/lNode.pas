implementation
type
    lnode = class(node)
    
constructor lnode(ilevel : integer, ienchNode : bEnchNode);
    level := ilevel;
    enchNode := ienchNode;
end;

private
    level := integer;
    enchNode := bEnchNode;

public
    function getnode()bEnchNode;
    begin
        result := enchNode;
    end;
    function getlevel()integer;
    begin
        result := level;
    end;
