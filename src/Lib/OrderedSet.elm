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

import Set exposing (Set)


type OrderedSet a
    = OrderedSet
        { set : Set a
        , list : List a
        }


empty : OrderedSet a
empty =
    OrderedSet
        { set = Set.empty
        , list = []
        }


fromList : List comparable -> OrderedSet comparable
fromList =
    List.foldl add empty


add : comparable -> OrderedSet comparable -> OrderedSet comparable
add item ((OrderedSet { set, list }) as orderedSet) =
    if Set.member item set then
        orderedSet

    else
        OrderedSet
            { set = Set.insert item set
            , list = item :: list
            }


remove : comparable -> OrderedSet comparable -> OrderedSet comparable
remove item (OrderedSet { set, list }) =
    OrderedSet
        { set = Set.remove item set
        , list = List.filter ((/=) item) list
        }


toList : OrderedSet a -> List a
toList (OrderedSet { list }) =
    List.reverse list
