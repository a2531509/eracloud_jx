<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	$(function(){
		createSysCode({
			id:"lss_Flag",
			codeType:"LSS_FLAG",
			isShowDefaultOption:false,
			value:"<%=com.erp.util.Constants.LSS_FLAG_SMGS%>",
			width:160
		});
	});
	function saveCardLos(){
		var row = $cardInfoGrid.datagrid("getSelected");
		if(row){
			var tt = $("#lss_Flag").combobox("getText");
			if(tt == "请选择"){
				$.messager.alert("系统消息","请选择挂失类型","error",function(){
					$("#lss_Flag").combobox("showPanel");
				});
				return;
			}
			$.messager.confirm("系统消息","您确定要" + tt + "卡号为【" + row.CARD_NO + "】的卡片吗？",function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.ajax({
						url:"cardService/cardServiceAction!tosavegs.action?cardNo=" + row.CARD_NO,
						data:$("#gsAgtInfo").serialize(),
						success: function(rsp){
							$.messager.progress("close");
							rsp = $.parseJSON(rsp);
							$.messager.alert("系统消息",rsp.message,(rsp.status ? "info":"error"),function(){
								if(rsp.status){
									showReport("卡片挂失",rsp.dealNo);
									$cardInfoGrid.datagrid("reload");
									$("#gsAgtInfo").form("reset");
								}
							});
						},
						error:function(){
							$.messager.progress("close");
							$.messager.alert("系统消息","挂失卡片发生错误：请求失败，请重试！","error");
						}
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一行将要进行挂失的卡片记录！","error");
		}
	}
	function readCardGsAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#gsAgtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#gsAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#gsAgtName").val(dealNull(queryCertInfo["name"]));
	}
	
	function readSMKGsAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#gsAgtCertType").combobox("setValue","1");
		$("#gsAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#gsAgtName").val(dealNull(queryCertInfo["name"]));
	}
</script>

<form id="gsAgtInfo">
<h3 class="subtitle">挂失信息</h3>
	<table class="tablegrid">
	 	 <tr>
	 	    <td class="tableleft" style="width: 15%">挂失类型：</td>
			<td class="tableright"><input name="lss_Flag" id="lss_Flag" value="2" class="textinput" type="text"></td>
	 	 </tr>
	 
	</table>
	<h3 class="subtitle">代理人信息</h3>
	<table class="tablegrid" style="width:100%;">
		<tr>
			<th class="tableleft" style="width: 15%">代理人证件类型：</th>
			<td class="tableright"><input id="gsAgtCertType" name="rec.agtCertType" type="text" class="textinput"/> </td>
			<th class="tableleft">代理人证件号码：</th>
			<td class="tableright"><input id="gsAgtCertNo" name="rec.agtCertNo" type="text" class="textinput agt-info easyui-validatebox"  validtype="idcard" maxlength="18"/></td>
			<th class="tableleft">代理人姓名：</th>
			<td class="tableright"><input id="gsAgtName" name="rec.agtName" type="text" class="textinput agt-info easyui-validatebox" maxlength="50"/></td>
		</tr>
		<tr>
		 	<td class="tableleft">代理人联系电话：</td>
			<td class="tableright"><input id="hkAgtTelNo" name="rec.agtTelNo" type="text" class="agt-info textinput" maxlength="11"/></td>
			<td class="tableright" colspan="4" style="padding-left: 5%">
				<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardGsAgt()">读身份证</a>
				&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMKGsAgt()">读市民卡</a>
				&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveCardLos()">确定</a>
			</td>
		</tr>
    </table>
</form>