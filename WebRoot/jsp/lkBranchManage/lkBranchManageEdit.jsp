<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script type="text/javascript">
	$(function(){
		if("${defaultErrorMasg}" != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		$("#isBatchHf2").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"是"},
				{value:"1", text:"否"}
			],
			editable:false
		});
		
		createSysBranch({id:"branchId2",value:"${lkBranchId}", isJudgePermission:false,
			editable:true,
			loadFilter:function(data){
				var rows = data.rows;
				removeNode(rows);
				return rows;
			}, 
			onLoadSuccess:function(m, n){
			if (n && n.length > 0) {
				var e = $("#branchId2").val();
				if (e == "erp2_erp2") {
					e = ""
				}
				if (dealNull(e) == "") {
					e = n[0].id
				}
				if (e != "" && e != "erp2_erp2" && n.length == 1) {
					$("#branchId2").combotree("readonly", true)
				} else {
					$("#branchId2").combobox("readonly", false)
				}
				var o = $("#branchId2").combotree("options");
				if (typeof (o.isReadOnly) == "boolean" && o.isReadOnly == true) {
					$("#branchId2").combotree("readonly", true)
				}
				$("#branchId2").combotree("setValue", e);
			}
		}});
		createSysBranch({id:"branchId3",value:"${lkBranchId2}",isJudgePermission:false, onLoadSuccess:function(m, n){
			if (n && n.length > 0) {
				var e = $("#branchId3").val();
				if (e == "erp2_erp2") {
					e = ""
				}
				if (dealNull(e) == "") {
					e = n[0].id
				}
				if (e != "" && e != "erp2_erp2" && n.length == 1) {
					$("#branchId3").combotree("readonly", true)
				} else {
					$("#branchId3").combobox("readonly", false)
				}
				var o = $("#branchId3").combotree("options");
				if (typeof (o.isReadOnly) == "boolean" && o.isReadOnly == true) {
					$("#branchId3").combotree("readonly", true)
				}
				$("#branchId3").combotree("setValue", e);
			}
		}});
	});
	function removeNode(childs){
			if(childs.length > 0 ){
				for(var j = 0; j < childs.length; j++){
					var childs2 = childs[j].children;
					if(childs2 && childs2.length > 0){
						removeNode(childs2);
						if(childs2.length == 0){
							childs.splice(j--, 1);
						}
					} else if(childs[j].isLkBrch == "1"){
						var a = childs.splice(j--, 1);
					}
				}
			}
	}
	function settingLkBranch(){
		if($("#isCorpOrComm2").val() != "0" && $("#isCorpOrComm2").val() != "1"){
			$.messager.alert("系统消息","获取操作类型错误！","error");
			return;
		}
		if($("#corpOrCommId2").val() == ""){
			$.messager.alert("系统消息","获取单位编号/社区（村）编号错误！","error");
			return;
		}
		$.messager.confirm("系统消息","您确定要设置该信息吗？",function(e){
			if(e){
				$.messager.progress({title : "提示",text : "数据处理中，请稍后...."});
				$.post("lkBranch/lkBranchAction!settingLkBranch.action",$("#form").serialize(),function(data,status){
					$.messager.progress("close");
					if(status == "success"){
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
							if(data.status == "0"){
								if($("#isCorpOrComm2").val() == "0"){
									showReport("领卡网点设置", data.dealNo, function(){
										$lkBranchDataGrid.datagrid("reload");
										$.modalDialog.handler.dialog("destroy");
										$.modalDialog.handler = undefined;
									});
								} else {
									$lkBranchDataGrid.datagrid("reload");
									$.modalDialog.handler.dialog("destroy");
									$.modalDialog.handler = undefined;
								}
							}
						});
					 }else{
						$.messager.alert("系统消息","设置单位/社区（村）领卡网点信息出现错误，请重新进行操作！","error");
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
			<s:hidden name="isCorpOrComm" id="isCorpOrComm2"></s:hidden>
			<table class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft" style="width:20%">单位编号/社区（村）编号：</td>
					<td class="tableright" style="width:30%"><input type="text" name="corpOrCommId" id="corpOrCommId2" class="textinput" value="${corpOrCommId}" readonly="readonly"/></td>
					<td class="tableleft" style="width:20%">单位名称/社区（村）名称：</td>
					<td class="tableright" style="width:30%"><input type="text" name="corpOrCommName" class="textinput" value="${corpOrCommName}" readonly="readonly"/></td>
				</tr>
				<tr>
					<td class="tableleft" style="width:8%">金融市民卡领卡网点：</td>
					<td class="tableright" style="width:17%"><input type="text" name="lkBranchId" id="branchId2" class="textinput" value="${lkBranchId}"/></td>
					<td class="tableleft" style="width:8%">全功能卡领卡网点：</td>
					<td class="tableright" style="width:17%"><input type="text" name="lkBranchId2" id="branchId3" class="textinput" value="${lkBranchId2}"/></td>
				</tr>
				<c:if test="${isCorpOrComm eq '0'}">
					<tr>
						<td class="tableleft">是否完成换发：</td>
						<td class="tableright"><input type="text" name="isBatchHf" id="isBatchHf2" class="textinput" value="${isBatchHf}"/></td>
					</tr>
				</c:if>
			</table>
		</form>
	</div>
</div>