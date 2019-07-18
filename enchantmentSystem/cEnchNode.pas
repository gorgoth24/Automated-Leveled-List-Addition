implementation
type
    cEnchNode = class(node)
private
    EnchCost : integer;
    Ench : IInterface;
public
    constructor create(iEnch : IInterface, iEnchCost : integer);
        EnchCost := iEnchCost;
        Ench := iEnch;
    end;
    //getters
    function getFormId()Cardinal;
        result := FormId;
    end;
    function getEnchCost()Integer;
        result := EnchCost;
    end;