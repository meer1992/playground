module Main where

import Text.ParserCombinators.Parsec
import System.IO

csvFile :: GenParser Char st [[String]]
csvFile = line `endBy` eol

line :: GenParser Char st [String]
line = cell `sepBy` (char ',')

cell :: GenParser Char st String
cell = quotedCell <|> regularCell

regularCell :: GenParser Char st String
regularCell = many (noneOf [',', '\n', '\r'])

quotedCell :: GenParser Char st String
quotedCell = char '"' >> many quotedChar >>= \r -> char '"' >> return r

quotedChar :: GenParser Char st Char
quotedChar = noneOf ['"'] <|> quotedDoubleQuote

quotedDoubleQuote :: GenParser Char st Char
quotedDoubleQuote = try (string (replicate 2 '"') >> return '"')

eol :: GenParser Char st ()
eol = try (string "\r\n" >> return ())
  <|> (string "\n" >> return ())
  <|> (string "\r" >> return ())
  <?> "end of line"

parseCsv :: String -> Either ParseError [[String]]
parseCsv input = parse csvFile "(stdin)" input

main :: IO ()
main = do
  c <- getContents
  case parseCsv c of
    Right r -> mapM_ print r
    Left  e -> hPutStrLn stderr $ "Error parsing input:\n" ++ (show e)
