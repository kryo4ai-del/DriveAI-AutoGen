"""Marketing Agents — 11 Agents (MKT-01 bis MKT-11)."""

from factory.marketing.agents.brand_guardian import BrandGuardian
from factory.marketing.agents.brand_guardian import SYSTEM_MESSAGE as BRAND_GUARDIAN_SYSTEM_MESSAGE
from factory.marketing.agents.strategy import StrategyAgent
from factory.marketing.agents.strategy import SYSTEM_MESSAGE as STRATEGY_SYSTEM_MESSAGE
from factory.marketing.agents.copywriter import Copywriter
from factory.marketing.agents.copywriter import SYSTEM_MESSAGE as COPYWRITER_SYSTEM_MESSAGE
from factory.marketing.agents.naming_agent import NamingAgent
from factory.marketing.agents.naming_agent import SYSTEM_MESSAGE as NAMING_SYSTEM_MESSAGE
from factory.marketing.agents.aso_agent import ASOAgent
from factory.marketing.agents.aso_agent import SYSTEM_MESSAGE as ASO_SYSTEM_MESSAGE
from factory.marketing.agents.visual_designer import VisualDesigner
from factory.marketing.agents.visual_designer import SYSTEM_MESSAGE as VISUAL_DESIGNER_SYSTEM_MESSAGE
from factory.marketing.agents.video_script_agent import VideoScriptAgent
from factory.marketing.agents.video_script_agent import SYSTEM_MESSAGE as VIDEO_SCRIPT_SYSTEM_MESSAGE
from factory.marketing.agents.publishing_orchestrator import PublishingOrchestrator
from factory.marketing.agents.report_agent import ReportAgent
from factory.marketing.agents.report_agent import SYSTEM_MESSAGE as REPORT_SYSTEM_MESSAGE
from factory.marketing.agents.review_manager import ReviewManager
from factory.marketing.agents.review_manager import SYSTEM_MESSAGE as REVIEW_MANAGER_SYSTEM_MESSAGE
from factory.marketing.agents.community_agent import CommunityAgent
from factory.marketing.agents.community_agent import SYSTEM_MESSAGE as COMMUNITY_SYSTEM_MESSAGE

__all__ = [
    "BrandGuardian", "StrategyAgent", "Copywriter", "NamingAgent", "ASOAgent",
    "VisualDesigner", "VideoScriptAgent", "PublishingOrchestrator",
    "ReportAgent", "ReviewManager", "CommunityAgent",
    "BRAND_GUARDIAN_SYSTEM_MESSAGE", "STRATEGY_SYSTEM_MESSAGE",
    "COPYWRITER_SYSTEM_MESSAGE", "NAMING_SYSTEM_MESSAGE", "ASO_SYSTEM_MESSAGE",
    "VISUAL_DESIGNER_SYSTEM_MESSAGE", "VIDEO_SCRIPT_SYSTEM_MESSAGE",
    "REPORT_SYSTEM_MESSAGE", "REVIEW_MANAGER_SYSTEM_MESSAGE", "COMMUNITY_SYSTEM_MESSAGE",
]
