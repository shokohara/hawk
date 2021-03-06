{-# LANGUAGE OverloadedStrings #-}
-- | The precisely-typed version of Hawk's command-line arguments.
module System.Console.Hawk.Args.Spec where

import Data.ByteString (ByteString)


data HawkSpec
    = Help
    | Version
    | Eval  ExprSpec           OutputSpec
    | Apply ExprSpec InputSpec OutputSpec
    | Map   ExprSpec InputSpec OutputSpec
  deriving (Show, Eq)


data InputSpec = InputSpec
    { inputSource :: InputSource
    , inputFormat :: InputFormat
    }
  deriving (Show, Eq)

data OutputSpec = OutputSpec
    { outputSink :: OutputSink
    , outputFormat :: OutputFormat
    }
  deriving (Show, Eq)


data InputSource
    = NoInput
    | UseStdin
    | InputFile FilePath
  deriving (Show, Eq)

data OutputSink
    = UseStdout
    -- OutputFile FilePath  -- we might want to implement --in-place
                            -- in the future
  deriving (Show, Eq)

data InputFormat
    = RawStream
    | Records Separator RecordFormat
  deriving (Show, Eq)

data RecordFormat
    = RawRecord
    | Fields Separator
  deriving (Show, Eq)

-- We can't know ahead of time whether it's going to be a raw stream
-- or raw records or fields, it depends on the type of the user expression.
data OutputFormat = OutputFormat
    { recordDelimiter :: Delimiter
    , fieldDelimiter :: Delimiter
    }
  deriving (Show, Eq)


-- A separator is a strategy for separating a string into substrings.
-- One such strategy is to split the string on every occurrence of a
-- particular delimiter.
type Delimiter = ByteString
data Separator = Whitespace | Delimiter Delimiter
  deriving (Show, Eq)

fromSeparator :: Separator -> Delimiter
fromSeparator Whitespace     = " "
fromSeparator (Delimiter "") = " "
fromSeparator (Delimiter d)  = d


newtype ContextSpec = ContextSpec
    { userContextDirectory :: FilePath
    }
  deriving (Show, Eq)

type UntypedExpr = String

data ExprSpec = ExprSpec
    { contextSpec :: ContextSpec
    , untypedExpr :: UntypedExpr
    }
  deriving (Show, Eq)

defaultInputSpec, noInput :: InputSpec
defaultInputSpec = InputSpec UseStdin defaultInputFormat
noInput          = InputSpec NoInput  defaultInputFormat

defaultOutputSpec :: OutputSpec
defaultOutputSpec = OutputSpec UseStdout defaultOutputFormat


defaultInputFormat :: InputFormat
defaultInputFormat = Records defaultRecordSeparator
                   $ Fields defaultFieldSeparator

defaultOutputFormat :: OutputFormat
defaultOutputFormat = OutputFormat defaultRecordDelimiter defaultFieldDelimiter


defaultRecordSeparator, defaultFieldSeparator :: Separator
defaultRecordSeparator = Delimiter defaultRecordDelimiter
defaultFieldSeparator = Whitespace

defaultRecordDelimiter, defaultFieldDelimiter :: Delimiter
defaultRecordDelimiter = "\n"
defaultFieldDelimiter = " "
