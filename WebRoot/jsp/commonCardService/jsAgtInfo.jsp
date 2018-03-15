<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	function saveCardUnLos(){
		var row = $cardInfoGrid.datagrid("getSelected");
		if(row){
			$.messager.confirm("系统消息","您确定要对卡号为【" + row.CARD_NO + "】的卡片进行解挂吗？",function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("cardService/cardServiceAction!toSaveJg.action",$("#jsAgtInfo").serialize() + "&selectId=" + row.CARD_NO,function(data){
						$.messager.progress("close");
						$.messager.alert("系统消息",data.message,(data.status ? "info":"error"),function(){
							if(data.status){
								showReport("卡片解挂",data.dealNo);
								$cardInfoGrid.datagrid("reload");
								$("#jsAgtInfo").form("reset");
							}
						});
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条卡信息进行解挂！","error");
		}
	}
	function readCardJgAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#jsAgtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#jsAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#jsAgtName").val(dealNull(queryCertInfo["name"]));
	}
	
	function readSMKJgAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#jsAgtCertType").combobox("setValue","1");
		$("#jsAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#jsAgtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<h3 class="subtitle">代理人信息</h3>
<form id="jsAgtInfo">
	<table class="tablegrid" style="width:100%;">
		<tr>
			<th class="tableleft">代理人证件类型：</th>
			<td class="tableright"><input id="jsAgtCertType" name="rec.agtCertType" type="text" class="textinput"/> </td>
			<th class="tableleft">代理人证件号码：</th>
			<td class="tableright"><input id="jsAgtCertNo" name="rec.agtCertNo" type="text" class="textinput agt-info easyui-validatebox"  validtype="idcard" maxlength="18"/></td>
			<th class="tableleft">代理人姓名：</th>
			<td class="tableright"><input id="jsAgtName" name="rec.agtName" type="text" class="textinput agt-info easyui-validatebox" maxlength="50"/></td>
	 		<th class="tableleft">代理人联系电话：</th>
			<td class="tableright"><input id="jsAgtTelNo" name="rec.agtTelNo"  type="text" class="textinput agt-info easyui-validatebox" validtype="mobile" maxlength="11" /></td>
		</tr>
		<tr>
			<td colspan="8" style="text-align:center;height:50px;">
				<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardJgAgt()">读身份证</a>
				&nbsp;&nbsp;
				<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMKJgAgt()">读市民卡</a>
				&nbsp;&nbsp;
				<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveCardUnLos()">解挂失</a>
			</td>
		</tr>
    </table>
</form>