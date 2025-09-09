-- Shop Script Made By GiwrgxkhssDev ! Please Dont Delete Anything From Here!
-- Check Line 4 

local shop = script.Parent.ShopFrame -- Name your shop ShopFrame
local open = script.Parent.Open
local exit = shop.Exit

-- Open
open.MouseButton1Click:Connect(function()
	shop.Visible = true
	open.Visible = false
end)

-- Close
exit.MouseButton1Click:Connect(function()
    shop.Visible = false
	open.Visible = false
end)
