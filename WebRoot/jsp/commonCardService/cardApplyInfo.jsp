<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	var $cardApplyInfoGrid;
	$(function(){
		createRecvBranch({
			id:"cardApplyInfoLkBrchId",
			width:160,
			loadFilter:function(data){
				curBrchId = data.brchId;
				curBankId = data.bankId;
				var rows = data.rows;
				removeNode(rows);
				return rows;
			},
			onSelect:function(r){
				if(!$(this).tree('isLeaf', r.target)){
					jAlert("不能选择上级网点", "warning", function(){
						$("#cardApplyInfoLkBrchId").combotree('setValues', '');
					});
				}
			}
		});
		createSysCode({
			id:"cardApplyInfoBusType",
			value:"00",
			codeType:"BUS_TYPE",
			codeValue:"00",
			width:160,
			isShowDefaultOption:false
		});
		createLocalDataSelect({
			id:"cardApplyInfoDealState",
			data:[
			    {value:"0",text:"是"},
			    {value:"1",text:"否"}
			],
			value:"0",
			width:160,
		});
		createSysCode({
			id:"cardApplyInfoCardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			value:"<%=com.erp.util.Constants.CARD_TYPE_SMZK%>",
			isShowDefaultOption:false,
			onSelect:function(r){
				if(r.VALUE == "<%=com.erp.util.Constants.CARD_TYPE_QGN%>"){
					$("#cardApplyInfoBankId").combobox("select", "");
					$("#cardApplyInfoLkBrchId").combotree("setValue", "");
					$("#cardApplyInfoBankId").combobox("disable");
				} else {
					$("#cardApplyInfoBankId").combobox("enable");
					if(corpInfo && corpInfo.lkBrchId){
						$("#cardApplyInfoLkBrchId").combotree("setValue", corpInfo.lkBrchId);
					}
				}
			},
			width:160
		});
		createLocalDataSelect({
			id:"cardApplyInfoIsUrgent",
			value:"1",
			data:[
		        {value:"0",text:"本地制卡"},
		        {value:"1",text:"外包制卡"}
		    ],
		    width:160,
		    onSelect:function(r){
		    }
		});
		createCustomSelect({
			id:"cardApplyInfoBankId",
			value:"bank_id",
			text:"bank_name",
			table:"Base_Bank",
			where:"bank_state = '0'",
			isShowDefaultOption:true,
			orderby:"bank_id asc",
			from:1,
			to:30,
			width:160,
			onSelect:function(r){
				var select = $("#cardApplyInfoLkBrchId").combotree("getValue");
				$("#cardApplyInfoLkBrchId").combotree('clear');
				$("#cardApplyInfoLkBrchId").combotree("reload","commAction!findAllRecvBranch.action?bankId=" + r.VALUE);
				if(select){
					$("#cardApplyInfoLkBrchId").combotree('setValue', select);
				}
				
			}
		});
		$cardApplyInfoGrid = createDataGrid({
			id:"cardApplyInfo",
			url:"cardapply/cardApplyAction!queryOneCardApply.action",
			fit:false,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			scrollbarSize:0,
			singleSelect:true,
			fitColumns:false,
		    frozenColumns:[[
				{field:"IDS",checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true},
				{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"CERTTYPE",title:"证件类型",sortable:true},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
				{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
				{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.13)},     
				{field:"BUY_PLAN_ID",title:"批次号",sortable:true,width:parseInt($(this).width() * 0.07)},
				{field:"TASK_ID",title:"任务编号",sortable:true}
		    ]],
			columns:[[
				{field:"APPLYTYPE",title:"申领类型",sortable:true},
				{field:"APPLYWAY",title:"申领方式",sortable:true},
				{field:"APPLYSTATE",title:"申领状态",sortable:true},
				{field:"IS_JUDGE_SB_STATE",title:"是否判断社保",sortable:true, formatter:function(v){
					if(v == 1){
						return "否";
					} else {
						return "是";
					}
				}},
                {field:"LK_BRCH_NAME",title:"领卡网点",sortable:true},
                {field:"BANK_ID",title:"银行编号",sortable:true},
                {field:"BANK_NAME",title:"银行名称",sortable:true},
                {field:"BANK_CHECKREFUSE_REASON",title:"审核结果",sortable:true},
				{field:"BRCH_NAME",title:"申领网点",sortable:true},
				{field:"APPLY_USER_ID",title:"申领柜员",sortable:true},
				{field:"APPLY_DATE",title:"申领时间",sortable:true},
				{field:"IS_URGENT",title:"制卡方式",sortable:true},
				{field:"CORPNAME",title:"申领单位",sortable:true},
				{field:"REGION_NAME",title:"所属区域",sortable:true},
				{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true},
				{field:"COMM_NAME",title:"社区（村）",sortable:true},
				{field:"AGT_CERT_TYPE",title:"申领代理人证件类型",sortable:true},
				{field:"AGT_CERT_NO",title:"申领代理人证件号码",sortable:true},
				{field:"AGT_NAME",title:"申领代理人姓名"},
				{field:"AGT_PHONE",title:"申领代理人联系电话"}
		    ]],
		    onLoadSuccess:function(data){
		    	if(data.status != 0){
		       		$.messager.alert("系统消息",data.msg,"error");
		       		return;
		       	}
	       		if(dealNull($("#personalCertNo").val()).length > 0){
	       			/* commonDwr.judgeBusType($("#personalCertNo").val(),function(data){
	       				$("#cardApplyInfoBusType").combobox("setValue",data["busType"]);
	       			}); */
	       		}
	       		$("#cardApplyInfoFlag").val(data.applyFlag);
		    }
		});
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
	function cardApplyInfoQuery(){
		var certNo = $("#personalCertNo").val();
		if(dealNull(certNo) == ""){
			$.messager.alert("系统消息","请输入证件号码！","error");
			return;
		}
	    $cardApplyInfoGrid.datagrid("load",{
		    queryType:"0",
			certNo:$("#personalCertNo").val()
		});
	}
	function cardApplyInfoToApply(){
		if(dealNull($("#personalInfoCustomerId").val()) == ""){
			$.messager.alert("系统消息","请先进行客户信息查询再进行申领！","error");
			return;
		}
		var certNo = $("#personalCertNo").val();
		if(dealNull(certNo) == ""){
			$.messager.alert("系统消息","证件号码不能为空,请先进行客户信息查询再进行申领！","error");
			return;
		}
		if(dealNull($("#personalInfoResideType").combobox("getValue")) == ""){
			$.messager.alert("系统消息","户籍类型不能为空，请到客户信息管理修改该客户籍类型信息！","error");
			return;
		}
		if(dealNull($("#personalInfoRegionId").combobox("getValue")) == ""){
			$.messager.alert("系统消息","所属区域不能为空，请到客户信息管理修改该客户所属区域信息！","error");
			return;
		}
		if(dealNull($("#personalInfoGender").combobox("getValue")) == ""){
			$.messager.alert("系统消息","性别不能为空，请到客户信息管理修改该客户性别信息！","error");
			return;
		}
		if(dealNull($("#cardApplyInfoFlag").val()) != ""){
			if(dealNull($("#cardApplyInfoFlag").val()) == "0"){
				$.messager.alert("系统消息","已存在申领记录，不能重复申领！","error");
				return;
			}
		}
		if(dealNull($("#cardApplyInfoBusType").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择公交类型！","error");
			return;
		}
		if(dealNull($("#cardApplyInfoBankId").combobox("getValue")) == "" && $("#cardApplyInfoCardType").combobox("getValue") == "<%=com.erp.util.Constants.CARD_TYPE_SMZK%>"){
			$.messager.alert("系统消息","请选择银行！","error",function(){
				$("#cardApplyInfoBankId").combobox("showPanel");
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要进行申领吗？",function(r){
			if(r){
				$.messager.progress({text:"正在进行申领，请稍后...."});
				$.post("cardapply/cardApplyAction!saveOneCardApply.action", 
				{ 
				    "apply.busType":$("#cardApplyInfoBusType").combobox("getValue"),
				    "apply.isUrgent":$("#cardApplyInfoIsUrgent").combobox("getValue"),
				    costFee:$("#cardApplyInfoCostFee").combobox("getValue"),
				    urgentFee:$("#cardApplyInfoUrgentFee").combobox("getValue"),
				    bankId:$("#cardApplyInfoBankId").combobox("getValue"),
				    agtCertType:$("#cardApplyInfoAgtCertType").combobox("getValue"),
				    agtCertNo:$("#cardApplyInfoAgtCertNo").val(),
				    agtName:$("#cardApplyInfoAgtName").val(),
				    agtTelNo:$("#cardApplyInfoAgtTelNo").val(),
				    customerId:$("#personalInfoCustomerId").val(),
				    "apply.cardType":$("#cardApplyInfoCardType").combobox("getValue"),
				    "rec.dealState":($("#cardApplyInfoDealState").combobox("getValue")),
				    "apply.recvBrchId":$("#cardApplyInfoLkBrchId").combobox("getValue")
				},
				function(data){
					$.messager.progress("close");
			     	if(data.status == "0"){
			     		$.messager.alert("系统消息","申领保存成功","info",function(){
			     			showReport("个人卡片申领",data.dealNo);
			     			$cardApplyInfoGrid.datagrid("reload");
			     			$("#cardApplyInfoAgt").form("reset");
			     		});
			     	}else{
			     		$.messager.alert("系统消息",data.msg,"error");
			     	}
				},"json");
			}
		});
	}
	function readCardApplyAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#cardApplyInfoAgtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
		$("#cardApplyInfoAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#cardApplyInfoAgtName").val(dealNull(queryCertInfo["name"]));
	}
	
	function readSMKApplyAgt(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#cardApplyInfoAgtCertType").combobox("setValue","1");
		$("#cardApplyInfoAgtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#cardApplyInfoAgtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<table id="cardApplyInfo" style="height:120px;"></table>
<div>
	<form id="cardApplyInfoAgt">
		<input type="hidden" id="cardApplyInfoFlag" name="cardApplyInfoFlag"  />
		<h3 class="subtitle">制卡信息</h3>
		<table class="tablegrid">
			<tr>
				<th class="tableleft" style="width:10%">卡类型：</th>
				<td class="tableright" style="width:19%"><input  id="cardApplyInfoCardType" name="apply.cardType" type="text"  class="textinput" value="100" /></td>
				<th class="tableleft" style="width:10%">银行名称：</th>
				<td class="tableright" style="width:19%"><input id="cardApplyInfoBankId" name="bankId" type="text" class="textinput easyui-validatebox" /></td>
				<th class="tableleft" style="width:10%">公交类型：</th>
				<td class="tableright" style="width:19%"><input  id="cardApplyInfoBusType" name="busType" type="text"  class="textinput" /></td>
			</tr>
			<tr>
				<th class="tableleft">制卡方式：</th>
				<td class="tableright"><input id="cardApplyInfoIsUrgent" name="isUrgent" class="textinput" value="0" type="text"/></td>
			    <th class="tableleft">领卡网点：</th>
				<td class="tableright">
					<input id="cardApplyInfoLkBrchId" name="cardApplyInfoLkBrchId" type="text" class="textinput">
				</td>
				<td class="tableleft">是否判断医保状态：</td>
		    	<td class="tableright">
					<input id="cardApplyInfoDealState" name="dealState" type="text" class="textinput">
				</td>
			</tr>
			<tr>
			    <th class="tableleft">工本费：</th>
			    <td class="tableright" ><input id="cardApplyInfoCostFee" name="costFee" type="text" class="textinput" readonly="readonly"/></td>
				<th class="tableleft">加急费：</th>
				<td class="tableright" colspan="3"><input id="cardApplyInfoUrgentFee" name="urgentFee" type="text" class="textinput" readonly="readonly"/></td>
	 	    </tr>
		</table>

	      <h3 class="subtitle">代理人信息</h3>
			<table class="tablegrid">
			<tr>
				<th class="tableleft" style="width:10%">代理人证件类型：</th>
				<td class="tableright"  style="width:19%"><input id="cardApplyInfoAgtCertType" name="agtCertType" type="text" class="textinput"/></td>
				<th class="tableleft" style="width:10%">代理人证件号码：</th>
				<td class="tableright"  style="width:19%"><input id="cardApplyInfoAgtCertNo" name="agtCertNo" type="text" class="textinput easyui-validatebox agt-info" maxlength="18" validtype="idcard"/></td>
				<th class="tableleft" style="width:10%">代理人姓名：</th>
				<td class="tableright"  style="width:19%"><input id="cardApplyInfoAgtName" name="agtName" type="text" class="textinput agt-info" maxlength="30"/></td>
			</tr>
			<tr>
				<th class="tableleft">代理人联系电话：</th>
				<td class="tableright"><input id="cardApplyInfoAgtTelNo" name="agtTelNo" type="text" class="textinput easyui-validatebox agt-info"  maxlength="11" validtype="mobile"/></td>
				<td class="tableright" colspan="4" style="padding-left: 5%">
				    <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCardApplyAgt()">读身份证</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMKApplyAgt()">读市民卡</a>
					<shiro:hasPermission name="onecardApplySaveNotUsed">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="cardApplyInfoToApply();">确认申领</a>
					</shiro:hasPermission>
				</td>
			</tr>
		</table>
	</form>
</div>