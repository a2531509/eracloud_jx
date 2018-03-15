<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<script type="text/javascript">
	$(function(){
		if("${defaultErrorMasg}" != ''){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		createCustomSelect({
			id:"medWholeNo2",
			value:"city_id",
			text:"region_name",
			table:"base_region",
			where:"region_state = '0'",
			orderby:"city_id asc",
			onSelect:function(option){
				if(option && option.VALUE != ""){
					$("#medWholeNo2").val(option.TEXT);
				}else{
					$("#medWholeNo2").val("");
				}
			},
			onLoadSuccess:function(){
				var defaultValue = $("#medWholeNo2").combobox("getValue");
				var defaultText = "";
				if(defaultValue == "erp2_erp2"){
					defaultValue = "";
				}else{
					defaultText = $("#medWholeNo2").combobox("getText");
				}
				var alldatas =  $("#medWholeNo2").combobox("getData");
				if(dealNull(defaultValue) == ""){
					if(alldatas && alldatas.length > 0){
						defaultValue = alldatas[0].VALUE;
						defaultText = alldatas[0].TEXT;
					}
				}
				if(defaultValue != ""){
					$("#medWholeNo2").val(defaultText);
				}else{
					$("#medWholeNo2").val("");
				}
				$("#medWholeNo2").combobox('setValue',defaultValue);
			}
		});
		createSysCode({id:"certType2",codeType:"CERT_TYPE"});
		createLocalDataSelect({
			id:"medState2",
			data:[{value:'',text:"请选择"},{value:'0',text:"正常"},{value:'1',text:"不正常"}]
		});
		if("${baseSiinfo.id.medWholeNo}" != ""){
			$("#medWholeNo2").combobox("setValue","${baseSiinfo.id.medWholeNo}");
		}
		if("${baseSiinfo.certType}" != ""){
			$("#certType2").combobox("setValue","${baseSiinfo.certType}");
		}
		if("${baseSiinfo.medState}" != ""){
			$("#medState2").combobox("setValue","${baseSiinfo.medState}");
		}
	});
	
	function saveOrUpdateBaseSiinfo() {
		var subtitle = "";
		if($("#queryType").val() == "0"){
			subtitle = "新增";
		}else if($("#queryType").val() == "1"){
			subtitle = "编辑";
		}else{
			$.messager.alert("系统消息","获取操作类型错误！","error");
			return;
		}
		/*if(dealNull($("#medWholeNo2").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择医疗保险统筹区编码！","error",function(){
				$("#medWholeNo2").combobox("showPanel");
			});
			return;
		}*/
		if(dealNull($("#medState2").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择医保参保状态！","error",function(){
				$("#medState2").combobox("showPanel");
			});
			return;
		}
		$.messager.confirm("系统消息","确定要修改医保参保状态吗？",function(e){
			if(e){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("baseSiinfo/baseSiinfoAction!saveOrUpdateBaseSiinfo.action",$("#form").serialize(),function(data,status){
					$.messager.progress('close');
					if(status == "success"){
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
							if(data.status == "0"){
								$baseSiinfo.datagrid("reload");
								$.modalDialog.handler.dialog('destroy');
								$.modalDialog.handler = undefined;
							}
						});
					 }else{
						$.messager.alert("系统消息","修改医保参保状态出现错误，请重新进行操作！","error");
						return;
					 }
				},"json");
			}
		});
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" style="overflow:hidden;padding:0px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<s:hidden name="baseSiinfo.customerId"></s:hidden>
			<s:hidden name="preMedWholeNo" id="preMedWholeNo"></s:hidden>
			<s:hidden name="queryType" id="queryType"></s:hidden>
			<table class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft">社保编码：</td>
					<td class="tableright"><input name="baseSiinfo.id.personalId" id="personalId2" class="textinput easyui-validatebox" required="required" value="${baseSiinfo.id.personalId}"/></td>
					<td class="tableleft">医疗保险统筹区：</td>
					<td class="tableright"><input name="baseSiinfo.id.medWholeNo" id="medWholeNo2" class="textinput easyui-validatebox" type="text" value="${baseSiinfo.id.medWholeNo}"/></td>
				</tr>
				<tr>
					<td class="tableleft">客户姓名：</td>
					<td class="tableright"><input name="baseSiinfo.name" id="name2" class="textinput easyui-validatebox" type="text" value="${baseSiinfo.name}" required="required" maxlength="32" readonly="readonly"/></td>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="baseSiinfo.certNo" id="certNo2" class="textinput easyui-validatebox" type="text" validtype="idcard" value="${baseSiinfo.certNo}" required="required" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft">社保单位编码：</td>
					<td class="tableright"><input name="baseSiinfo.companyId" id="companyId2" class="textinput" value="${baseSiinfo.companyId}"/></td>
					<td class="tableleft">医保参保状态：</td>
					<td class="tableright"><input name="baseSiinfo.medState" id="medState2" class="textinput easyui-validatebox" validType="selectValueRequired['#medState']" value="${baseSiinfo.medState}"/></td>
				</tr>
			</table>
		</form>
	</div>
</div>