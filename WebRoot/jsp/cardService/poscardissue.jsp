<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<style>.tableleft{font-weight:600;}</style>
<script type="text/javascript">
	var mainkey = "";
	var merchantID = "";
	var dealDate = "";
	$(function(){
		$.autoComplete({
			id:"merchantId",
			text:"merchant_id",
			value:"merchant_name",
			table:"base_merchant",
			where:"merchant_state = '0'",
			keyColumn:"merchant_id",
			minLength:1
		},"merchantName");
		$.autoComplete({
			id:"merchantName",
			text:"merchant_name",
			value:"merchant_id",
			table:"base_merchant",
			where:"merchant_state = '0'",
			keyColumn:"merchant_name",
			minLength:1
		},"merchantId");
	});
	function save(){
		$.messager.progress({text:"正在获取该商户的主密钥信息，请稍后...."});
		if(dealNull($("#merchantId").val())==""){
			$.messager.progress("close");
			$.messager.alert("系统消息","请输入商户编号！","error");
			document.getElementById("merchantId").focus();
			return;
		}
		merchantID = $("#merchantId").val();
		$.post("cardService/cardServiceAction!getPosMainKey.action",{"merchantId":merchantID},function(data){
			$.messager.progress("close");
			if(data['status'] == '0'){
				mainkey = data['mainkey'];
				dealDate = data['dealDate'];
				$.messager.confirm("系统消息","获取该商户主密钥信息成功，请放置主密钥进行写卡...",function(r){
					var errmsg = makeposcard(merchantID,dealDate,mainkey);
					if(errmsg == 0){
						$.messager.alert('系统消息','写主密钥卡成功','info');
					}else{
						CardCtl.CardGetErrMessage(errmsg);
						var err = CardCtl.Outdata; 
						$.messager.alert('系统消息',err,'error');
					}
				});
			}else if(data["status"] == '1'){
				jAlert(data["msg"]);
			}
		},"json");
		
	}
</script>
<n:initpage  title="POS主密钥卡发放操作！<span style='color:red;'>注意：</span>每个商户对应唯一的pos主密钥卡，每个终端有自己的工作密钥！">
	<n:center>
	  	<div id="tb"  style="padding:2px 0;width:100%;height:100%" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:false,tools:'#toolspanel'" title="主密钥卡发行">
			<table class="tablegrid">
				<tr>
					<td style="width:15%" class="tableleft">商户编号：</td>
					<td style="width:20%" class="tableright"><input name="merchantId" data-options="required:true,invalidMessage:'请输入商户编号',missingMessage:'请输入商户编号'" class="textinput easyui-validatebox" id="merchantId" /></td>
					<td style="width:15%" class="tableleft">商户名称：</td>
					<td style="width:20%" class="tableright"><input name="merchantName" data-options="required:true,invalidMessage:'请输入商户名称',missingMessage:'请输入商户名称'" class="textinput easyui-validatebox" id="merchantName" type="text" /></td>
					<td style="width:30%" class="tableright">
						<a  data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0)" class="easyui-linkbutton" onclick="save()">确定修改</a>
					</td>
				</tr>
			</table>
		</div>
	</n:center>
</n:initpage>