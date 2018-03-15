<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>柜员调剂</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<style type="text/css">
	.combobox-item{
		cursor:pointer;
	}
</style>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript"> 
$(function() {
	if('${defaultErrorMsg}'.replace(/\s/g,'').length > 0){
		$.messager.alert('系统消息','${defaultErrorMsg}','error');//
	}
	$("#stkCode").combobox({ 
	    url:"stockManage/StockAction!findAllStkType.action",
	    editable:false,
	    cache: false,
	    panelHeight: 'auto',
	    valueField:'CODE_VALUE',   
	    textField:'CODE_NAME'
	});
	$("#otherBrchId").combobox({ 
	    url:"commAction!getAllBranchs.action",
	    editable:false,
	    cache: false,
	    panelHeight: 'auto',
	    valueField:'branch_Id',   
	    textField:'branch_Name',
	    formatter:function(row){
    		var temptext = "<span>";
	    	if(row.leval){
	    		for(var i = 0; i < (row.leval-1) * 8;i++){
	    			temptext += "&nbsp;";
	    		}
	    	}
    		return temptext + row.branch_Name +"</span>";
	    },
	    onLoadSuccess:function(){
	    	var options = $("#otherBrchId").combobox('getData');
	    	var len = options.length;
	    	if(len > 0){
	    		$(this).combobox('setValue',options[0].branch_Id);
		    	$("#otherUserId").combobox('reload','commAction!getAllOperators.action?branch_Id=' + options[0].branch_Id);
	    	}
	    },
	    onSelect:function(option){
	    	$("#otherUserId").combobox('clear');
	    	$("#otherUserId").combobox('reload','commAction!getAllOperators.action?branch_Id=' + option.branch_Id);
	    }
	}); 
	$("#otherUserId").combobox({ 
	    url:"commAction!getAllOperators.action",
	    editable:false,
	    cache: false,
	    panelHeight: 'auto',
	    valueField:'user_Id',   
	    textField:'user_Name',
	    onLoadSuccess:function(){
	    	var options = $(this).combobox('getData');
	    	var len = options.length;
	    	if(len > 0){
	    		$(this).combobox('setValue',options[0].user_Id);
	    	}
	    }
		});
});
//提交
function subTj(){
	if($("#otherBrchId").combobox('getValue') == '' || $("#otherUserId").combobox('getValue') == ''){
		$.messager.alert('系统消息','请选择上交接收网点和柜员！','error',function(){
			if($("#otherBrchId").combobox('getValue') == ''){
				$("#otherBrchId").combobox('showPanel');
			}
			if($("#otherUserId").combobox('getValue') == ''){
				$("#otherUserId").combobox('showPanel');
			}
		});
		return;
	}
	if($("#inTellerPwd").val().replace(/\s/g,'').length == 0){
		$.messager.alert('系统消息','请输入收方柜员密码！','error',function(){
			$('#inTellerPwd').focus();
		});
		return;
	}
	if($("#stkCode").combobox('getValue') == ''){
		$.messager.alert('系统消息','请选择上交库存代码种类！','error',function(){
			$('#inTellerPwd').focus();
		});
		return;
	}
	if($("#beginGoodsNo").val().replace(/\s/g,'').length == 0){
		$.messager.alert('系统消息','请输入物品起始编号！','error',function(){
			$('#beginGoodsNo').focus();
		});
		return;
	}
	if($("#endGoodsNo").val().replace(/\s/g,'').length == 0){
		$.messager.alert('系统消息','请输入物品截止编号！','error',function(){
			$('#endGoodsNo').focus();
		});
		return;
	}
	$.messager.confirm('系统消息','您确定要向【' + $("#otherBrchId").combobox('getText') + "-->" + $("#otherUserId").combobox('getText') + "】<br>上交<" + $("#stkCode").combobox('getText') + ">吗？",function(is){
		if(is){
			$.messager.progress({
				text : '数据处理中，请稍后....'
			});
			$.get('/stockManage/StockAction!toTellerSj.action',$('#tellerTransfer').serialize(),function(data,status){
				$.messager.progress('close');
				if(status == 'success'){
					$.messager.alert('系统消息',data.message,(data.status == '0' ? 'info' : 'error'),function(){
						/* if(data.status == '0'){
							showReport('柜员上交',data.dealNo,function(){
								window.location.href = window.location.href + "?mm=" + Math.random();
							});
						}else{
							if(data.isreload == '0'){
								window.location.href = window.location.href + "?mm=" + Math.random();
							}
						} */
					});
				}else{
					$.messager.alert('系统消息','上交出现错误，请重试!','error',function(){
						window.history.go(0);
					});
				}
			},'json');
		}
	});
}
</script>
</head>
<body class="easyui-layout datagrid-toolbar" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>库存物品进行上交操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:false,fit:true" style="height:auto;border-bottom:none;border-left:none;">
		<form id="tellerTransfer">
			<div title="当前柜员(付方)信息" class="easyui-panel" data-options="iconCls:'title_header'">   
			   <table cellpadding="0" cellspacing="0" style="width:100%;background-color:rgb(245,245,245);" class="tablegrid">
					<tr>
						<td class="tableleft" width="16%" height="30">当前柜员所属网点：</td>
						<td class="tableright" width="18%"><input id="brchName" type="text" readonly="readonly" disabled="disabled" value="${brchName}" class="textinput" name="brchName"  style="width:174px;"/></td>
						<td class="tableleft" width="10%">当前柜员名称：</td>
						<td class="tableright" width="20%"><input id="userName" type="text" readonly="readonly" disabled="disabled" value="${userName}" class="textinput" name="userName"  style="width:174px;"/></td>
					</tr>
				</table>
			</div> 
			<div title="收方柜员信息" class="easyui-panel"  data-options="iconCls:'title_header',fit:true,border:false">
				<table cellpadding="0" cellspacing="0" style="width:100%;background-color:rgb(245,245,245);" class="tablegrid">
					<tr>
						<td class="tableleft" width="16%">收方柜员所属网点：</td>
						<td class="tableright" width="18%"><input id="otherBrchId" type="text" class="easyui-combobox  easyui-validatebox" name="otherBrchId" style="width:177px;"/></td>
						<td class="tableleft" width="10%">收方柜员名称：</td>
						<td class="tableright" width="20%"><input id="otherUserId" type="text" class="easyui-combobox  easyui-validatebox" name="otherUserId"  style="width:177px;"/></td>
						<td class="tableleft">收方柜员密码：</td>
						<td colspan="1" class="tableright"><input id="inTellerPwd" type="password" class="textinput" maxlength="6" name="inTellerPwd"  style="width:174px;"/></td>
					</tr>
					<tr>
						<th class="tableleft">库存代码：</th>
						<td class="tableright"><input name="stock.id.stkCode" id="stkCode" class="textinput"/></td>
						<td class="tableleft">物品起始编号：</td>
						<td class="tableright"><input id="beginGoodsNo" type="text" class="textinput easyui-validatebox" name="beginGoodsNo"  style="width:174px;" data-options="required:true,missingMessage:'请输入库存物品辅助编号（卡片卡号，设备号）',invalidMessage:'请输入库存物品辅助编号（卡片卡号，设备号）'"/></td>
						<td class="tableleft">物品截止编号：</td>
						<td class="tableright"><input id="endGoodsNo" type="text" class="textinput easyui-validatebox" name="endGoodsNo"  style="width:174px;" data-options="required:true,missingMessage:'请输入库存物品辅助编号（卡片卡号，设备号）',invalidMessage:'请输入库存物品辅助编号（卡片卡号，设备号）'"/></td>
					</tr>
					<tr>
						<td colspan="6" align="center" style="padding-left:2px;height:80px;">
							<a style="text-align:center;margin:0 auto;margin-right:100px;" data-options="iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="subTj()">确认上交</a>
						</td>
					</tr>
				</table>
			</div>
		</form>
	  </div>
</body>
</html>