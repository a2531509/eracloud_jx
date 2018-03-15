<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%-- 
#*---------------------------------------------#
# Template for a JSP
# @version: 1.2
# @author: yangn
# @author: Jed Anderson
# @describle:功能说明： 库存账户开户
#---------------------------------------------#
--%>
<script type="text/javascript">
	$(function() {
		$.autoComplete({
			id:"userId2",
			text:"user_id",
			value:"name",
			table:"sys_users",
			keyColumn:"user_id"
		},"userName2");
		$.autoComplete({
			id:"userName2",
			text:"name",
			value:"user_id",
			table:"sys_users",
			keyColumn:"name",
			minLength:"1"
		},"userId2");
		
		createSysCode({id:"stkType2",codeType:"STK_TYPE",onSelect:function(node){
			var options = $("#stkCode2").combobox("options");
			var params = options["queryParams"];
			params["where"] = "stk_code like '" + node.VALUE + "%'";
			if(node.VALUE == ""){
				params["isOnlyDefault"] = true;
			}else{
				params["isOnlyDefault"] = false;
			}
			params["isShowDefaultOption"] = false;
			$("#stkCode2").combobox("clear");
			$("#stkCode2").combobox("reload",params);
		}});
		
		createCustomSelect({
			id:"stkCode2",
			value:"stk_code",
			text:"stk_name",
			table:"stock_type",where:"stk_code is not null ",
			orderby:"stk_code asc",
			isOnlyDefault:true,
			onSelect:function(option){
				if(option && option.VALUE != ""){
					$("#accName2").val(option.TEXT);
				}else{
					$("#accName2").val("");
				}
			},
			onLoadSuccess:function(){
				var defaultValue = $("#stkCode2").combobox("getValue");
				var defaultText = "";
				if(defaultValue == "erp2_erp2"){
					defaultValue = "";
				}else{
					defaultText = $("#stkCode2").combobox("getText");
				}
				var alldatas =  $("#stkCode2").combobox("getData");
				if(dealNull(defaultValue) == ""){
					if(alldatas && alldatas.length > 0){
						defaultValue = alldatas[0].VALUE;
						defaultText = alldatas[0].TEXT;
					}
				}
				if(defaultValue != ""){
					$("#accName2").val(defaultText);
				}else{
					$("#accName2").val("");
				}
				$("#stkCode2").combobox('setValue',defaultValue);
			}
		});
	});
	function saveStockAccOpen(){
		var formdata = getformdata("stockaccopen");
		var finaltitle = "您确认要为";
		if(!formdata["stockAcc.id.userId"] == ""){
			finaltitle += "柜员" + $("#userName2").val();
		} else {
			jAlert("柜员编号不能为空！", "warning");
			return;
		}
		if(formdata["stockType.stkType"] == ""){
			//$.messager.alert("系统消息","请选择库存账户开户库存种类！","error",function(){
				//$("#stkType2").combobox("showPanel");
			//});
			//return;
		}
		if(formdata["stockAcc.id.stkCode"] == ""){
			//$.messager.alert("系统消息","请选择库存账户开户库存类型！","error",function(){
				//$("#stkCode2").combobox("showPanel");
			//});
			//return;
			finaltitle += "创建所有库存类型的账户吗？";
		}else{
			finaltitle += "创建" + $("#stkCode2").combobox("getText") + "库存账户吗？";
		}
		if(formdata["stockAcc.accName"] == ""){
			//$.messager.alert("系统消息","库存账户名称不能为空！","error");
			//return;
		}
		$.messager.confirm("系统消息",finaltitle,function(r){
			if(r){
				$.messager.progress({text : '数据处理中，请稍后....'});
				$.post("stockManage/stockManageAction!saveStockAccAdd.action",$("#stockaccopen").serialize(),function(data,status){
					$.messager.progress('close');
					if(status =="success"){
						if(data.status == "0"){
							$.messager.alert("系统消息",data.msg,"info",function(){
								$dg.datagrid("reload");
								$.modalDialog.handler.dialog("destroy");
								$.modalDialog.handler = undefined;
							});
						}else{
							$.messager.alert("系统消息",data.msg,"error");
						}
					}else{
						$.messager.alert("系统消息","创建库存账户发生错误，请重试！","error");
					}
				},"json");
			}
		});
	}
</script>
<n:layout>
	<n:north title="柜员进行库存账户开户操作！<span style='color:red;'>注意：</span>该开户操作支持指定柜员开户，网点批量开户！"/>
	<n:center layoutOptions="title:'库存账户开户'">
		<form id="stockaccopen" method="post" style="width:100%;height:100%" class="datagrid-toolbar">
			<table class="tablegrid">
				 <tr>
					 <th class="tableleft">柜员编号：</th>
					 <td class="tableright"><input id="userId2" name="stockAcc.id.userId" type="text" class="textinput" value="${stockAcc.brchId}"/></td>
					 <th class="tableleft">柜员姓名 ：</th>
					 <td class="tableright"><input id="userName2" type="text" class="textinput"></td>
				 </tr>
				 <tr>
				  	 <th class="tableleft" style="width:15%;">库存种类 ：</th>
					 <td class="tableright" style="width:25%;"><input id="stkType2" name="stockType.stkType" type="text" class="textinput" value="${stockType.stkType}"/></td>
				     <th class="tableleft" style="width:15%">库存类型 ：</th>
					 <td class="tableright" style="width:25%;"><input id="stkCode2" name="stockAcc.id.stkCode" type="text" class="textinput" value="${stockAcc.id.stkCode}"/></td>
					 <th class="tableleft" style="width:15%;">账户名称：</th>
					 <td class="tableright" style="width:25%;padding-right:60px;"><input id="accName2" name="stockAcc.accName" type="text" class="textinput easyui-validatebox" value="${stockAcc.accName}" readonly="readonly" maxlength="10"/> </td>
				 </tr>
				 <tr>
					 <th class="tableleft">备注：</th>
					 <td class="tableright" colspan="5"><input id="note2" name="stockAcc.note" type="text" class="textinput" value="${stockAcc.note}" style="width:885px;" maxlength="50"/></td>
				</tr>
			 </table>
		</form>
	</n:center>
</n:layout>