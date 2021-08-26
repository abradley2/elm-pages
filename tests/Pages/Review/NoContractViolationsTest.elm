module Pages.Review.NoContractViolationsTest exposing (all)

import Pages.Review.NoContractViolations exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "Pages.Review.NoContractViolations"
        [ test "reports error when missing exposed declaration" <|
            \() ->
                """module Page.Blog.Slug_ exposing (Data, Msg, page)

a = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Unexposed Declaration in Page Module"
                            , details =
                                [ """Page Modules need to expose the following values:

- page
- Data
- Model
- Msg

But it is not exposing: Model"""
                                ]
                            , under = "module Page.Blog.Slug_ exposing (Data, Msg, page)"
                            }
                        ]
        , test "reports RouteParams mismatch" <|
            \() ->
                """module Page.Blog.Slug_ exposing (Data, page, Model, Msg)

type alias RouteParams = { blogPostName : String }

page = {}
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "RouteParams don't match Page Module name"
                            , details =
                                [ """Expected

type alias RouteParams = { slug : String }
"""
                                ]
                            , under = "type alias RouteParams = { blogPostName : String }"
                            }
                        ]
        , test "no error for matching RouteParams name" <|
            \() ->
                """module Page.Blog.Slug_ exposing (Data, page, Model, Msg)

type alias RouteParams = { slug : String }

page = {}
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "error when RouteParams type is not a record" <|
            \() ->
                """module Page.Blog.Slug_ exposing (Data, page, Model, Msg)

type alias RouteParams = ()

page = {}
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "RouteParams must be a record type alias."
                            , details =
                                [ """Expected a record type alias."""
                                ]
                            , under = "type alias RouteParams = ()"
                            }
                        ]
        , test "no error for modules that don't start with Page prefix" <|
            \() ->
                """module NotPageModule.Blog.Slug_ exposing (Model, Msg)

type alias RouteParams = ()

page = {}
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]