<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
	//页面初始化控件
	$(function() {
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		
		$("#dealCodeone").combobox({
			url:"/pointManage/pointManageAction!findAllDealCode.action",
			width:174,
			valueField:"DEAL_CODE",
			editable:false,
		    textField:"DEAL_CODE_NAME"
		});
		
		$("#pointTypeone").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'',codeName:"请选择"},{codeValue:'1',codeName:"固定积分"},{codeValue:'2',codeName:"比例积分"}],
		    onSelect:function(node){
		    	if(node.codeValue == '1'){
		    		$("#pointBlValue").attr("readonly","readonly");
		    		$('#pointGdValue').removeAttr("readonly");
		    		$('#pointBlValue').val('');
		    		$('#pointGdValue').val();
		    		$("#pointGdValue").validatebox({required:true,validType:"email",invalidMessage:"请输固定积分的值<br/><span style=\"color:red\">提示：固定积分值为数字</span>",missingMessage:"请输固定积分的值<br/><span style=\"color:red;\">提示：固定积分值为数字</span>"});
		    	}else if(node.codeValue == '2'){
		    		$("#pointGdValue").attr("readonly","readonly");
		    		$('#pointBlValue').removeAttr("readonly");
		    		$('#pointBlValue').val('');
		    		$('#pointGdValue').val('');
		    		$("#pointBlValue").validatebox({required:true,validType:"email",invalidMessage:"请输比例积分的值<br/><span style=\"color:red\">提示：比例积分值为数字</span>",missingMessage:"请输固定积分的值<br/><span style=\"color:red;\">提示：比例积分值为数字</span>"});
		    	}else{
		    		$('#pointGdValue').removeAttr("readonly");
		    		$('#pointBlValue').removeAttr("readonly");
		    		$('#pointBlValue').val('');
		    		$('#pointGdValue').val('');
		    	}
		    }
		});
		$("#stateone").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"注销"}]
		});
		
		
	});
	//表单提交
	function save(oldgrid){
		if(dealNull($("#dealCodeone").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择交易代码","error",function(){
				$("#dealCodeone").combobox('showPanel');
			});
			return false;
		}
		if(dealNull($("#pointTypeone").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","请选择积分类型！","error",function(){
				$("#pointTypeone").combobox('showPanel');
			});
			return false;
		}
		if(dealNull($("#pointTypeone").combobox("getValue"))=="1"&&dealNull($("#pointGdValue").val()).length == 0){
			$.messager.alert("系统消息","固定积分值不能为空！","error",function(){
				$("#pointGdValue").focus();
			});
			return false;
		}
		if(dealNull($("#pointTypeone").combobox("getValue"))=="2"&&dealNull($("#pointBlValue").val()).length == 0){
			$.messager.alert("系统消息","比例积分值不能为空！","error",function(){
				$("#pointGdValue").focus();
			});
			return false;
		} 
		if(dealNull($("#pointMaxValue").val()).length == 0){
			$.messager.alert("系统消息","最大积分值不能为空！","error",function(){
				$("#pointMaxValue").focus();
			});
			return false;
		}
		
		if(dealNull($("#stateone").combobox("getValue")).length == 0){
			$.messager.alert("系统消息","积分状态不能为空！","error",function(){
				$("#stateone").focus();
			});
			return false;
		}
		$.messager.confirm("系统消息","您确认要<s:if test='%{pointId == \"\"}'>新增交易积分</s:if><s:else>编辑交易积分</s:else>【" + $("#dealCodeone").combobox('getText') + "】吗？",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("/pointManage/pointManageAction!pointParaSave.action",$("form").serialize(),function(data,status){
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
	function validRmb(obj){
		var v = obj.value;
		var exp = /^\d*(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			if(isNaN(v) && v.indexOf('..') <= -1){
				obj.value = v.replace(/([\D*)|([^\.])/g,'');
			}else{
				obj.value = v.substring(0,v.length - 1);
			}
		}
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false,fit:true" title="" style="overflow: hidden;padding:0px;background-color:rgb(245,245,245);">
		<form id="form" method="post">
			<h3 class="subtitle"><s:if test='%{pointId == ""}'>新增积分参数</s:if><s:else>编辑积分参数</s:else></h3>
			<input name="queryType" id="queryType" type="hidden" value="${queryType}" />
			<input name="pointpara.id" id="pointId" type="hidden" value="${pointpara.id}" />
			<table class="tablegrid" width="100%">
				 <tr>
				    <th class="tableleft"  width="25%">交易代码：</th>
					<td class="tableright" width="25%"><input value="${pointpara.dealCode}" name="pointpara.dealCode" id="dealCodeone" class="textinput" type="text" <s:if test='%{pointId != ""}'>readonly="readonly"</s:if> maxlength="2"  data-options="validType:'email',invalidMessage:'请选择交易代码',missingMessage:'请选择交易代码'"/></td>
				 	<th class="tableleft"  width="22%">积分类型：</th>
					<td class="tableright" width="28%"><input value="${pointpara.pointType}" name="pointpara.pointType" id="pointTypeone"  type="text" class="textinput" maxlength="10" data-options="validType:'email',invalidMessage:'请选择积分类型',missingMessage:'请选择积分类型'"/></td>
				 </tr>
				 <tr>
				    <th class="tableleft">固定费率值：</th>
					<td class="tableright"><input  value="${pointpara.pointGdValue}"  name="pointpara.pointGdValue"  id="pointGdValue"  class="textinput easyui-validatebox" type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)" /></td>
				 	<th class="tableleft">费率比例 ：</th>
					<td class="tableright"><input value="${pointpara.pointBlValue}" name="pointpara.pointBlValue"  id="pointBlValue" class="textinput easyui-validatebox"  type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)" /><span style="color:red;">‱<span></span></td>
				 </tr>
				 <tr>
					<th class="tableleft">最大费率值：</th>
					<td class="tableright"><input value="${pointpara.pointMaxValue}" name="pointpara.pointMaxValue"  id="pointMaxValue" class="textinput easyui-validatebox" required="required"  type="text"  data-options="invalidMessage:'请输入最大积分值',missingMessage:'请输入最大积分值'"/></td>
				 	<th class="tableleft">状态：</th>
					<td class="tableright"><input  value="${pointpara.state}"  name="pointpara.state"  id="stateone"  class="textinput easyui-validatebox" type="text" class="" <s:if test='%{pointId != ""}'>readonly="readonly"</s:if> data-options="validType:'email',invalidMessage:'请选择账户类型状态',missingMessage:'请选择账户类型状态'"/></td>
				 </tr>
			 </table>
		</form>
	</div>
</div>
