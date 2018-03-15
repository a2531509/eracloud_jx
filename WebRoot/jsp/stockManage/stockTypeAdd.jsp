<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="n" uri="/WEB-INF/tlds/erp2tag.tld" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
.cardtypespan{display:none;}
</style>
<script type="text/javascript">
	$(function() {
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		createSysCode({
			id:"stkType",
			codeType:"STK_TYPE",
			value:"${stockType.stkType}",
		    onSelect:function(node){
		    	if(node.VALUE == ""){
		    		$(".cardtypespan").hide();
		    		$("#stkCode").val("");
		    		$("#stkName").val("");
		    	}else if(node.VALUE == "1"){
		    		$(".cardtypespan").show();
		    		if($("#cardType").combobox("getValue") != ""){
		    			$("#stkCode").val($("#stkType").combobox("getValue") + $("#cardType").combobox("getValue"));
			    		$("#stkName").val($("#cardType").combobox("getText"));
		    		}
		    	}else{
		    		$(".cardtypespan").hide();
		    		var stockTypeText = $("#stkType").combobox("getText");
		    		$("#stkCode").val($("#stkType").combobox("getValue") + "100");
		    		$("#stkName").val(stockTypeText);
		    	}
		 	},
		 	onLoadSuccess:function(){
		 		if("${queryType}" == "1"){
		 			$(this).combobox("disable");
		 		}
		 		if("${stockType.stkType}" == "1"){
					$("#cardType").combobox("setValue","${stockType.stkCode}".substring(1));
					$(".cardtypespan").show();
				}
		 	}
		});
		createSysOrg("orgId");
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
		    onSelect:function(node){
		    	if(dealNull(node.VALUE) != "" && $("#stkType").combobox("getValue") == "1"){
		    		$("#stkCode").val($("#stkType").combobox("getValue") + $("#cardType").combobox("getValue"));
		    		$("#stkName").val($("#cardType").combobox("getText"));
		    	}else{
		    		$("#stkCode").val("");
		    		$("#stkName").val("");
		    	}
		 	},
		 	onLoadSuccess:function(){
		 		if("${stockType.stkType}" == "1" && ${queryType} == "1"){
		 			$(this).combobox("disable");
		 		}else{
		 			
		 		}
		 	}
		});
		createLocalDataSelect({
			id:"lstFlag",
		    data:[{value:"",text:"请选择"},{value:"0",text:"是"},{value:"1",text:"否"}],
		    onLoadSuccess:function(){
		    	if("${queryType}" == "1"){
					$("#lstFlag").combobox("setValue","${stockType.lstFlag}");
				}
		    }
		});
		createLocalDataSelect({
			id:"outFlag",
		    data:[{value:"",text:"请选择"},{value:"0",text:"柜员"},{value:"1",text:"网点"}],
		    required:true,    
		    validType:"email",
		    invalidMessage:"请选择该库存类型的出库方式<br/><span style=\"color:red\">提示：当设置库存出库方式为【柜员】时,该物品必须在该柜员名下才能进行出库操作;<br/>设置库存出库方式为【网点】时,同一网点下任何柜员都可以进行出库操作;</span>",
			missingMessage:"请选择该库存类型的出库方式<br/><span style=\"color:red\">提示：当设置库存出库方式为【柜员】时,该物品必须在该柜员名下才能进行出库操作;<br/>设置库存出库方式为【网点】时,同一网点下任何柜员都可以进行出库操作;</span>",
			onLoadSuccess:function(){
		    	if("${queryType}" == "1"){
					$("#outFlag").combobox("setValue","${stockType.outFlag}");
				}
			}
		});
	});
	function save(oldgrid){
		if(dealNull($("#stkType").combobox("getValue")).length == ""){
			$.messager.alert("系统消息","请勾选库存种类，库存种类不能为空！","error",function(){
				$("#stkType").combobox("showPanel");
			});
			return false;
		}
		if($("#stkType").combobox("getValue") == "1"){
			if($("#cardType").combobox("getValue") == ""){
				$.messager.alert("系统消息","库存类型也选择【智能卡】，请选择卡类型！","error",function(){
					$("#cardType").combobox("showPanel");
				});
				return false;
			}
		}
		if(dealNull($("#stkCode").val()).length == 0){
			$.messager.alert("系统消息","库存类型代码不能为空！","error",function(){
				$("#stkCode").focus();
			});
			return false;
		}
		if(dealNull($("#stkName").val()).length == 0){
			$.messager.alert("系统消息","库存类型名称不能为空！","error",function(){
				$("#stkName").focus();
			});
			return false;
		}
		if(dealNull($("#orgId").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择库存类型所属机构！","error",function(){
				$("#orgId").combobox("showPanel");
			});
			return false;
		}
		if(dealNull($("#lstFlag").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择该库存类型是否有明细！","error",function(){
				$("#lstFlag").combobox("showPanel");
			});
			return false;
		}
		if(dealNull($("#outFlag").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择该库存类型的出库方式！","error",function(){
				$("#outFlag").combobox("showPanel");
			});
			return false;
		}
		$.messager.confirm("系统消息","您确认要<s:if test='%{queryType == \"0\"}'>新增库存类型</s:if><s:else>编辑库存类型</s:else>【" + $("#stkName").val() + "】吗？",function(r){
			if(r){
				var tempstkcode = "";
				if("${queryType}" == "1"){
					tempstkcode = "&stockType.stkCode=" + $('#stkCode').val();
				}
				$.messager.progress({text:'数据处理中，请稍后....'});
				$.post("stockManage/stockManageAction!saveOrUpdateStockType.action",$("#stocktypeedit").serialize() + tempstkcode,function(data,status){
					$.messager.progress('close');
					$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						if(data.status == "0"){
							oldgrid.datagrid("reload",{queryType:"0"});
							$.modalDialog.handler.dialog('close');
						}
					});
				},"json");
			}
		});
		return true;
	}
</script>
<n:layout>
	<n:center cssClass="datagrid-toolbar">
		<form id="stocktypeedit" class="datagrid-toolbar" method="post" style="width:100%;height:100%;">
			<h3 class="subtitle"><s:if test='%{queryType == "0"}'>新增库存类型</s:if><s:else>编辑库存类型</s:else></h3>
			<input name="queryType" id="queryType" type="hidden" value="${queryType}" />
			<table class="tablegrid datagrid-toolbar" style="width:100%">
				 <tr>
				     <th class="tableleft"  width="15%">库存种类 ：</th>
					 <td class="tableright" width="25%"><input id="stkType" name="stockType.stkType" type="text" class="textinput" value="${stockType.stkType}"/></td>
				 	 <th class="tableleft"  width="25%">&nbsp;<span class="cardtypespan">卡类型：</span></th>
					 <td class="tableright" width="35%">&nbsp;<span class="cardtypespan"><input id="cardType" name="cardType" type="text" class="textinput"/></span></td>
				 </tr>
				 <tr>
				     <th class="tableleft">库存代码：</th>
					 <td class="tableright"><input id="stkCode" name="stockType.stkCode" type="text" class="textinput" value="${stockType.stkCode}" maxlength="4" <s:if test='%{queryType == "1"}'>disabled="disabled"</s:if>/></td>
					 <th class="tableleft">库存类型名称：</th>
					 <td class="tableright"><input id="stkName" name="stockType.stkName" type="text" class="textinput easyui-validatebox" value="${stockType.stkName}" maxlength="10" <s:if test='%{queryType == "1"}'>disabled="disabled"</s:if> data-options="validType:'email',invalidMessage:'请输入库存类型名称',missingMessage:'请输入库存类型名称'"/></td>
				 </tr>
				 <tr>
				     <th class="tableleft">所属机构：</th>
					 <td class="tableright"><input id="orgId" name="stockType.orgId" type="text" class="textinput easyui-combotree" value="${stockType.orgId}" data-options="validType:'email',invalidMessage:'请选择所属机构',missingMessage:'请选择所属机构'"/></td>
				     <th class="tableleft">是否有明细：</th>
					 <td class="tableright"><input id="lstFlag" name="stockType.lstFlag" type="text" class="textinput easyui-validatebox" value="${stockType.lstFlag}" data-options="validType:'email',invalidMessage:'请选择该库存类型是否有明细信息',missingMessage:'请选择该库存类型是否有明细信息'"/></td>
				 </tr>
				 <tr>
					 <th class="tableleft">出库方式：</th>
					 <td class="tableright" colspan="1"><input id="outFlag" name="stockType.outFlag" type="text" class="textinput" value="${stockType.outFlag}"/></td>
					 <th class="tableleft">备注：</th>
					 <td class="tableright" colspan="1"><input id="note" name="stockType.note" type="text" class="textinput" value="${stockType.note}" maxlength="50"/></td>
				</tr>
			 </table>
		</form>
	</n:center>
</n:layout>