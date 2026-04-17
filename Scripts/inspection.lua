local function inspection(x, n)
    local fields = x:GetType():GetFields(Reflector.HiddenFlags)
    if n == nil then
        for _, v in list_items(fields) do
            printf("%s[%s] = %s", v.Name, v.FieldType, tostring(v:GetValue(x)))
        end
    else
        for _, v in list_items(fields) do
            if v.Name == n then
                printf("%s[%s] = %s", v.Name, v.FieldType, tostring(v:GetValue(x)))
            end
        end
    end
end
return inspection
