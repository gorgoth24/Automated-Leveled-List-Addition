implementation
type
    cEnchNode = class(node)

constructor cEnchNode(iFormId : Cardinal, iEnchCost : Integer);
    EnchCost := iEnchCost;
    FormId := iFormId;
end;
    
private
    FormId : Cardinal;
    EnchCost : integer;
public
    function getFormId()Cardinal;
        result := FormId;
    end;
    function getEnchCost()Integer;
        result := EnchCost;
    end;