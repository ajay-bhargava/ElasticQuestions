###############################################################################
#
#  Welcome to Baml! To use this generated code, please run the following:
#
#  $ pip install baml-py
#
###############################################################################

# This file was generated by BAML: please do not edit it. Instead, edit the
# BAML files and re-generate this code.
#
# ruff: noqa: E501,F401
# flake8: noqa: E501,F401
# pylint: disable=unused-import,line-too-long
# fmt: off
import baml_py
from enum import Enum

from pydantic import BaseModel, ConfigDict

from typing_extensions import TypeAlias, Literal
from typing import Dict, Generic, List, Optional, TypeVar, Union


T = TypeVar('T')
CheckName = TypeVar('CheckName', bound=str)

class Check(BaseModel):
    name: str
    expression: str
    status: str
class Checked(BaseModel, Generic[T,CheckName]):
    value: T
    checks: Dict[CheckName, Check]

def get_checks(checks: Dict[CheckName, Check]) -> List[Check]:
    return list(checks.values())

def all_succeeded(checks: Dict[CheckName, Check]) -> bool:
    return all(check.status == "succeeded" for check in get_checks(checks))



class Category(str, Enum):
    
    QUERY_DSL = "QUERY_DSL"
    AGGREGATIONS = "AGGREGATIONS"
    SCRIPTING = "SCRIPTING"

class ElasticQuestion(BaseModel):
    category: "Category"
    question: str
    endpoint: str
    method: Union[Literal["GET"], Literal["POST"], Literal["PUT"], Literal["DELETE"]]
    answer: str

class ElasticSet(BaseModel):
    corpus: "ElasticQuestion"
    rating: Union[Literal["Good"], Literal["Bad"]]
