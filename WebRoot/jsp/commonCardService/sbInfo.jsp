<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	$(function(){
		createCustomSelect({
			id:"sbInfoMedWholeName",
			value:"city_id",
			text:"region_name",
			table:"base_region",
			where:"region_state = '0'",
			orderby:"city_id asc",
			hasDownArrow:false,
			width:160
		});
	});
	function initSbInfo(data){
		if(typeof(data) == "object" && typeof(data.sbInfo) != "undefined"){
			$("#sbInfoPersonalId").val(data.sbInfo.id.personalId);
			$("#sbInfoCompanyId").val(data.sbInfo.companyId);
			$("#sbInfoMedWholeNo").val(data.sbInfo.id.medWholeNo);
			$("#sbInfoMedWholeName").combobox("setValue", data.sbInfo.id.medWholeNo);
			$("#sbInfoEndowState").val(data.sbInfo.endowState == "0" ? "正常" : "不正常");
			$("#sbInfoMedState").val(data.sbInfo.medState == "0" ? "正常" : "不正常");
			$("#sbInfoInjuryState").val(data.sbInfo.injuryState == "0" ? "正常" : "不正常");
			$("#sbInfoBearState").val(data.sbInfo.bearState == "0" ? "正常" : "不正常");
			$("#sbInfoUnempState").val(data.sbInfo.unempState == "0" ? "正常" : "不正常");
			$("#sbInfoMedCertNo").val(data.sbInfo.medCertNo);
		} else {
			$("#sbInfoPersonalId").val("");
			$("#sbInfoCompanyId").val("");
			$("#sbInfoMedWholeNo").val("");
			$("#sbInfoMedWholeName").combobox("setValue", "");
			$("#sbInfoEndowState").val("");
			$("#sbInfoMedState").val("");
			$("#sbInfoInjuryState").val("");
			$("#sbInfoBearState").val("");
			$("#sbInfoUnempState").val("");
			$("#sbInfoMedCertNo").val("");
		}
	}
</script>
<table class="tablegrid" style="width: 100%;">
	<tr>
		<td class="tableleft" style="width: 8%;">社保编号：</td>
		<td class="tableright" style="width: 17%;"><input type="text" class="textinput" id="sbInfoPersonalId" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">社保单位编号：</td>
		<td class="tableright" style="width: 17%"><input type="text" class="textinput" id="sbInfoCompanyId" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">统筹区编码：</td>
		<td class="tableright" style="width: 17%"><input type="text" class="textinput" id="sbInfoMedWholeNo" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">统筹区名称：</td>
		<td class="tableright" style="width: 17%"><input type="text" class="textinput" id="sbInfoMedWholeName" readonly="readonly" /></td>
	</tr>
	<tr>
		<td class="tableleft" style="width: 8%;">养老参保状态：</td>
		<td class="tableright" style="width: 17%;"><input type="text" class="textinput" id="sbInfoEndowState" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">医保参保状态：</td>
		<td class="tableright" style="width: 17%"><input type="text" class="textinput" id="sbInfoMedState" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">工伤参保状态：</td>
		<td class="tableright" style="width: 17%"><input type="text" class="textinput" id="sbInfoInjuryState" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">生育参保状态：</td>
		<td class="tableright" style="width: 17%"><input type="text" class="textinput" id="sbInfoBearState" readonly="readonly" /></td>
	</tr>
	<tr>
		<td class="tableleft" style="width: 8%;">失业参保状态：</td>
		<td class="tableright" style="width: 17%;"><input type="text" class="textinput" id="sbInfoUnempState" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">医疗证号：</td>
		<td class="tableright" style="width: 17%;"><input type="text" class="textinput" id="sbInfoMedCertNo" readonly="readonly" /></td>
		<td class="tableleft" style="width: 8%;">&nbsp;</td>
		<td class="tableright" style="width: 17%">&nbsp;</td>
		<td class="tableleft" style="width: 8%;">&nbsp;</td>
		<td class="tableright" style="width: 17%">&nbsp;</td>
	</tr>
</table>