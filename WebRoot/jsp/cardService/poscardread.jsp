<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<style>
	.tableleft{
		font-weight:600;
	}
</style>
<script type="text/javascript">
function readPosCard(){
	$.messager.progress({text : '正在读取pos主密钥卡,请稍后...'});
	cardinfo = cardReadPosCard();
	if(dealNull(cardinfo["bizid"]).length == 0){
		$.messager.progress('close');
		$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error',function(){
			window.history.go(0);
		});
		return false;
	}
	getMerchantInfo(cardinfo["bizid"]);
	$("#poscardValue").val(cardinfo["posvardvalue"]);
}

function getMerchantInfo(bizid){
	$.post("cardService/cardServiceAction!getPosMainKeyMerInfo.action","merchantId=" + bizid,function(data,status){
		$.messager.progress("close");
		if(data.status == "0"){
			$("#merchantName").val(data.merchantName);
		}else{
			$.messager.alert("系统消息","验证商户信息发生错误，请重试...","error",function(){
				window.history.go(0);
			});
		}
	},"json").error(function(){
		$.messager.alert("系统消息","验证商户信息发生错误，请重试...","error",function(){
			window.history.go(0);
		});
	});
}
</script>
<n:initpage title="读取主密钥卡信息！<span style='color:red;'>注意：</span>每个商户对应一个商户主密钥信息！">
	<n:center>
		<div id="tb"  style="padding:2px 0;width:100%;height:100%" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:false,tools:'#toolspanel'" title="读取主密钥卡信息">
			<table class="tablegrid">
				<tr>
					<td style="width:10%" class="tableleft">商户编号：</td>
					<td style="width:20%" class="tableright"><input name="merchantId"   class="textinput easyui-validatebox" id="merchantId" /></td>
					<td style="width:10%" class="tableleft">商户名称：</td>
					<td style="width:20%" class="tableright"><input name="merchantName"   class="textinput easyui-validatebox" id="merchantName" /></td>
					<td style="width:10%" class="tableleft">主密钥值：</td>
					<td style="width:20%" class="tableright"><input name="poscardValue"   class="textinput easyui-validatebox" id="poscardValue" /></td>
					<td style="width:10%" class="tableright">
						<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0)" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readPosCard()">读取主密钥卡</a>
					</td>
				</tr>
			</table>
		</div>
	</n:center>
</n:initpage>