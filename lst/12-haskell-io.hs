-- getLine :: IO String
-- putStrLn :: String -> IO () -- note that the result value is an empty tuple.

import Data.Char

upCase = map toUpper

printUpCase :: String -> IO ()
printUpCase line = putStrLn (upCase line)

main :: IO ()
main = (getLine >>= printUpCase) >> main


main2 = do
  l <- getLine
  putStrLn (upCase l)
  mainx
