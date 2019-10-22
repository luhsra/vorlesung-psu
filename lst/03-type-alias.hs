type    X =   Char -- X ist nur ein zweiter Name
newtype Y = MakeY Char -- Y ist ein separater Typ
a :: X;   a = 'a'
b :: Y;   b = (MakeY 'a')
