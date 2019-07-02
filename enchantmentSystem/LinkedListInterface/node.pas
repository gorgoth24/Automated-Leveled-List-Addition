interface
type
    node = class
protected
    next : node;
public
    function getnext()node;
        result := node;
    end;
    procedure addnode(inode : node);
        next := inode
    end;