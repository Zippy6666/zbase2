local Name = "ZBaseDummyInit" -- Don't forget to change this!


hook.Add("Initialize", Name, function()

    -- Change the icon of your category
    if ZBaseInstalled then
        ZBaseSetCategoryIcon( "Dummies", "entities/zippy.png" )
    end
    
end)