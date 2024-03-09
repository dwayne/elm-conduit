module Lib.OrderedSet exposing
    ( OrderedSet
    , add
    , empty
    , fromList
    , remove
    , toList
    )

--
-- Properties:
--
-- 1. The insertion order is preserved.
-- 2. The elements are unique.
--


type OrderedSet a
    = OrderedSet (List a)


empty : OrderedSet a
empty =
    OrderedSet []


fromList : List a -> OrderedSet a
fromList =
    List.foldl add empty


add : a -> OrderedSet a -> OrderedSet a
add item ((OrderedSet list) as orderedSet) =
    if List.member item list then
        orderedSet

    else
        OrderedSet (item :: list)


remove : a -> OrderedSet a -> OrderedSet a
remove item (OrderedSet list) =
    list
        |> List.filter ((/=) item)
        |> OrderedSet


toList : OrderedSet a -> List a
toList (OrderedSet list) =
    List.reverse list
