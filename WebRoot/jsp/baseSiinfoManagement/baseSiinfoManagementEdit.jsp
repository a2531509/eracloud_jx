<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@include file="../../layout/initpage.jsp" %>
<script type="text/javascript">
    var isCanRe = "0";
	var baseSiinfo;
	var regionData;
	var errMsg;
	var cardinfo;
	$(function(){
		createCustomSelect({
			id:"medWholeNo1",
			value:"city_id",
			text:"city_name",
			table:"base_city",
			isShowDefaultOption:false,
			where:"nvl(city_type,'1') <> '2'",
			hasDownArrow:false,
			defaultValue:" ",
			orderby:"city_id desc",
			from:1,
			to:20
		});
		createCustomSelect({
			id:"medWholeNo2",
			value:"city_id",
			text:"city_name",
			table:"base_city",
			isShowDefaultOption:false,
			where:"nvl(city_type,'1') <> '2'",
			hasDownArrow:false,
			defaultValue:" ",
			orderby:"city_id desc",
			from:1,
			to:20
		});
	});
	function readCard(){
		try{
		$.messager.progress({text:"正在验证卡信息,请稍后..."});
		cardinfo = getTouchCardInfo_9901();
		var cardinfo2 = getTouchCardInfo_9902();
		for(var key in cardinfo2){
			cardinfo[key] = cardinfo2[key];
		}
		if(dealNull(cardinfo["sub_Card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error",function(){
				window.history.go(0);
			});
			return false;
		}
		var subCardId = cardinfo["card_Flag"];
		var subCardNo = cardinfo["sub_Card_No"];
		
		var certNo = cardinfo["cert_No"];
		$("#medWholeNo1").combobox("select",subCardId.substr(0,6));
		$("#personalId1").val(subCardId);
		$("#subCardNo").val(subCardNo);
		$("#certNo").val(certNo);
		$("#name").val(cardinfo["name"]);
		getNewBaseSiinfo(certNo,subCardNo, function(){
			$.messager.progress("close");
		});
		}catch(e){
			defaultCatchErrMsg(e);
		}
	}
	function getNewBaseSiinfo(certNo,subCardNo,callback){
		$.post("baseSiinfo/baseSiinfoAction!getNewBaseSiinfo.action",{"baseSiinfo.certNo":certNo,subCardNo:subCardNo}, function(data){
			callback();
			if(data){
				if(data.status == "1"){
					jAlert(data.errMsg);
				}else{
					baseSiinfo = data.baseSiinfo;
					var medWholeNo = data.baseSiinfo.id.medWholeNo;
					if(dealNull(medWholeNo).length == 0){
						jAlert("新参保信息的统筹区域编码为空！");
					}else{
						var oldSubCardId = $("#personalId1").val();
						var newSubCardId = medWholeNo + oldSubCardId.substr(6);
						$("#medWholeNo2").combobox("select",medWholeNo);
						$("#personalId2").val(newSubCardId);
					}
				}
			} else {
				jAlert("请求出现异常，请重新进行操作！");
			}
		}, "json");
	}
	function writeCard(){
		if(!cardinfo || dealNull(cardinfo["sub_Card_No"]).length == 0){
			jAlert("请先进行读取以获取客户参保区域信息！");
			return;
		}
		if(subCardNo == ""){
			jAlert("请先进行读卡以获取社保卡号！");
			return;
		}
		var subCardNo = $("#subCardNo").val();
		var oldMedWholeNo = $("#medWholeNo1").combobox("getValue");
		var newMedWholeNo = $("#medWholeNo2").combobox("getValue");
		if(dealNull(newMedWholeNo) == ""){
			jAlert("客户新参保区域不能为空！");
			return;
		}
		if(dealNull(oldMedWholeNo) == dealNull(newMedWholeNo) && isCanRe != "0"){
			jAlert("客户新老参保区域相同，无需进行变更！");
			return;
		}
		if(newMedWholeNo == ""){
			jAlert("请查询新社保信息统筹区域！","error",function(){
				//$("#medWholeNo2").combobox("showPanel");
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要变更该客户的参保区域信息吗？",function(e) {
			if(e){
				$.messager.progress({text:"正在进行写卡, 请稍后..."});
				if(modifyTouchRegion(subCardNo,newMedWholeNo)){
					$.post("baseSiinfo/baseSiinfoAction!updateBaseSiinfo.action", 
					{
						"baseSiinfo.id.medWholeNo":newMedWholeNo,
						"baseSiinfo.id.personalId":baseSiinfo.id.personalId,
						"baseSiinfo.certNo":$("#certNo").val(),
						"subCardNo":$("#subCardNo").val(),
						"subCardId":$("#personalId2").val(),
						"oldSubCardId":$("#personalId1").val()
					}, function(data){
						if(data.status == "1"){
							errMsg = data.errMsg;
							if(modifyTouchRegion(subCardNo,oldMedWholeNo)){
								$.messager.progress("close");
								$.messager.alert("系统消息","统筹区域变更失败， " + errMsg,"error",function(){
									window.history.go(0);
								});
							}else{
								$.messager.progress("close");
								$.messager.alert("系统消息","统筹区域变更失败， 请重新进行写卡！","error");
								isCanRe = "0";
							}
						}else{
							$.messager.progress("close");
							$.messager.alert("系统消息","统筹区域变更成功, 请取走卡片！" + data.msg,"info",function(){
								window.history.go(0);
							});
						}
					}, "json");
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","写卡失败, 请重试","error");
				}
			}
		});
	}
</script>
<n:initpage title="医疗保险统筹区域变更！">
	<n:center layoutOptions="title:'医疗保险统筹区变更'" cssClass="datagrid-toolbar">
		<h3 class="subtitle">旧社保信息</h3>
		<table class="tablegrid" style="width: 100%">
			<tr>
				<td class="tableleft" style="width: 30%">医疗保险统筹区编码：</td>
				<td class="tableright" style="width: 20%"><input id="medWholeNo1" class="textinput" type="text" readonly="readonly" /></td>
				<td class="tableleft" style="width: 10%">社保卡编码：</td>
				<td class="tableright" style="width: 40%">
					<input id="personalId1" class="textinput" type="text" readonly="readonly" style="width: 250px"/>
					<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
				</td>
			</tr>
			<tr>
				<td class="tableleft" style="width: 30%">客户姓名：</td>
				<td class="tableright" style="width: 20%"><input id="name" class="textinput" type="text" readonly="readonly" /></td>
				<td class="tableleft" style="width: 10%">身份证号：</td>
				<td class="tableright" style="width: 40%"><input id="certNo" class="textinput" type="text" readonly="readonly" /></td>
			</tr>
			<tr>
				<td class="tableleft" style="width: 30%">社保卡号：</td>
				<td class="tableright" style="width: 20%"><input id="subCardNo" class="textinput" type="text" readonly="readonly" /></td>
				<td class="tableleft" style="width: 10%">&nbsp;</td>
				<td class="tableright" style="width: 40%">&nbsp;</td>
			</tr>
		</table>
		<h3 class="subtitle">新社保信息</h3>
		<table class="tablegrid" style="width: 100%">
			<tr>
				<td class="tableleft" style="width: 30%">医疗保险统筹区编码：</td>
				<td class="tableright" style="width: 20%"><input id="medWholeNo2" class="textinput" type="text" readonly="readonly" /></td>
				<td class="tableleft" style="width: 10%">社保卡编码：</td>
				<td class="tableright" style="width: 40%">
					<input id="personalId2" class="textinput" type="text" readonly="readonly" style="width: 250px"/>
					<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="writeCard()">写卡</a>
				</td>
			</tr>
		</table>
	</n:center>
</n:initpage>