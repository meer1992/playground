module NumExpr where

import Steshaw
import Data.List (intercalate)
import Test.QuickCheck

data Expr n
  = Atom n
  | Symbol String
  | Fn0 String
  | Fn1 String (Expr n)
  | Add (Expr n) (Expr n)
  | Mul (Expr n) (Expr n)
  | Div (Expr n) (Expr n)
  deriving (Eq)

instance (Show n) => Show (Expr n) where
  show = prettyShow

instance (Num n) => Num (Expr n) where
  fromInteger i = Atom (fromInteger i)
  e1 + e2 = e1 `Add` e2
  e1 * e2 = e1 `Mul` e2

instance Fractional n => Fractional (Expr n) where
  e1 / e2 = Div e1 e2

instance Floating n => Floating (Expr n) where
  sin n = Fn1 "sin" n
  pi = Fn0 "pi"

prettyShow :: (Show n) => (Expr n) -> String
prettyShow expr = f False expr
  where
    f _ (Atom n) = show n
    f _ (Symbol s) = s
    f _ (Fn0 name ) = name
    f _ (Fn1 name e) = name ++ "(" ++ f False e ++ ")"
    f braceRequired (Add e1 e2) = showExpr braceRequired "+" e1 e2
    f braceRequired (Mul e1 e2) = showExpr braceRequired "*" e1 e2
    f braceRequired (Div e1 e2) = showExpr braceRequired "/" e1 e2
    showExpr True op e1 e2 = "(" ++ f True e1 ++ op ++ f True e2 ++ ")"
    showExpr False op e1 e2 = f True e1 ++ op ++ f True e2

rpnShowExpr op e1 e2 = intercalate " " [rpnShow e1, rpnShow e2, op]

rpnShow :: (Show n) => (Expr n) -> String
rpnShow (Atom n)     = show n
rpnShow (Symbol s)   = s
rpnShow (Fn0 name)   = name
rpnShow (Fn1 name e) = (rpnShow e) ++ " " ++ name
rpnShow (Add e1 e2)  = rpnShowExpr "+" e1 e2
rpnShow (Mul e1 e2)  = rpnShowExpr "*" e1 e2
rpnShow (Div e1 e2)  = rpnShowExpr "/" e1 e2

simplify :: (Num n) => Expr n -> Expr n
simplify (Mul 1 e) = e
simplify (Mul e 1) = e
simplify (Add e1 e2) = Add (simplify e1) (simplify e2)
simplify other = other

testExpr :: Num a => a
testExpr = 2 * 5 + 3

--
-- QuickChecks
--

instance Arbitrary n => Arbitrary (Expr n) where
  arbitrary = arbitrary >>= \n -> return $ Atom n

prop_pretty_eg1 = (prettyShow $ 5 + 1 * 3) == "5+(1*3)"
prop_pretty_eg2 = (prettyShow $ 5 * 1 + 3) == "(5*1)+3"
prop_pretty_eg3 = (prettyShow $ simplify $ 5 + 1 * 3) == "5+3"
prop_pretty_eg4 = (prettyShow $ 5 + (Symbol "x") * 3) == "5+(x*3)"

prop_pretty_1 a@(Atom na) b@(Atom nb) c@(Atom nc) =
  (prettyShow $ a * b + c) == "(" ++ show na ++ "*" ++ show nb ++ ")+" ++ show nc
prop_pretty_2 a@(Atom na) b@(Atom nb) c@(Atom nc) =
  (prettyShow $ a + b * c) == show na ++ "+(" ++ show nb ++ "*" ++ show nc ++ ")"

prop_rpn_eg1 = (rpnShow $ 5 + 1 * 3) == "5 1 3 * +"
prop_rpn_eg2 = (rpnShow $ 5 * 1 + 3) == "5 1 * 3 +"
prop_rpn_eg3 = (rpnShow $ simplify $ 5 + 1 * 3) == "5 3 +"
prop_rpn_eg4 = (rpnShow $ 5 + (Symbol "x") * 3) == "5 x 3 * +"

prop_test_1 = testExpr == 13
prop_test_2 = rpnShow testExpr == "2 5 * 3 +"
prop_test_3 = prettyShow testExpr == "(2*5)+3"
prop_test_4 = testExpr + 5 == 18
prop_test_5 = prettyShow (testExpr + 5) == "((2*5)+3)+5"
prop_test_6 = rpnShow (testExpr + 5) == "2 5 * 3 + 5 +"
