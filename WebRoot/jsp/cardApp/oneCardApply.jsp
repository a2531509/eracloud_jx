<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type='text/javascript' src='dwr/interface/imgDeal.js'></script>
<script>
	var $grid;
	var corpInfo;
	$(function(){
		createRecvBranch({
			id:"lkBrchId",loadFilter:function(data){
				curBrchId = data.brchId;
				curBankId = data.bankId;
				var rows = data.rows;
				removeNode(rows);
				return rows;
			},
			onSelect:function(r){
				if(!$(this).tree('isLeaf', r.target)){
					jAlert("不能选择上级网点", "warning", function(){
						$("#lkBrchId").combotree('setValues', '');
					});
				}
			}
		});
		if("${defaultErrorMasg}" != ""){
			$.messager.alert("系统消息","${defaultErrorMasg}","error");
		}
		createLocalDataSelect({
			id:"dealState",
			data:[
			    {value:"0",text:"是"},
			    {value:"1",text:"否"}
			],
			value:"0"
		});
		createLocalDataSelect({
			id:"isUrgent",
			value:"1",
			data:[
		        {value:"0",text:"本地制卡"},
		        {value:"1",text:"外包制卡"}
		    ],
		    onSelect:function(r){
		    }
		});
		createSysCode({
			id:"busType",
			value:"00",
			codeType:"BUS_TYPE",
			isShowDefaultOption:false,
			codeValue:"00"
		});
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		})
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			value:"<%=com.erp.util.Constants.CARD_TYPE_SMZK%>",
			isShowDefaultOption:false,
			onSelect:function(r){
				if(r.VALUE == "<%=com.erp.util.Constants.CARD_TYPE_QGN%>"){
					$("#bankId").combobox("select", "");
					$("#lkBrchId").combotree("setValue", "");
					$("#bankId").combobox("disable");
				} else {
					$("#bankId").combobox("enable");
					if(corpInfo && corpInfo.lkBrchId){
						$("#lkBrchId").combotree("setValue", corpInfo.lkBrchId);
					}
				}
			}
		});
		createCustomSelect({
			id:"bankId",
			value:"bank_id",
			text:"bank_name",
			table:"Base_Bank",
			where:"bank_state = '0'",
			isShowDefaultOption:true,
			orderby:"bank_id asc",
			from:1,
			to:30,
			onSelect:function(r){
				var select = $("#lkBrchId").combotree("getValue");
				$("#lkBrchId").combotree('clear');
				$("#lkBrchId").combotree("reload","commAction!findAllRecvBranch.action?bankId=" + r.VALUE);
				if(select){
					$("#lkBrchId").combotree('setValue', select);
				}
			}
		});
		createLocalDataSelect({
			id:"costFee",
			value:"${costFee}",
			data:[{value:"${costFee}",text:"${costFee}"}]
		});
		createLocalDataSelect({
			id:"urgentFee",
			value:"${urgentFee}",
			data:[{value:"${urgentFee}",text:"${urgentFee}"}]
		});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			to:10
		},"customerName");
		$grid = createDataGrid({
			id:"dg",
			url:"cardapply/cardApplyAction!queryOneCardApply.action",
			pagination:false,
			border:false,
			//fit:true,
			//height:180,
			//fitColumns:true,
			singleSelect:true,
			scrollbarSize:0,
			frozenColumns:[[
				//{field:"IDS",checkbox:true},
				{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.07)},
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
                {field:"BANK_ID",title:"银行编号",sortable:true},
                {field:"BANK_NAME",title:"银行名称",sortable:true},
                {field:"BANK_CHECKREFUSE_REASON",title:"审核结果",sortable:true},
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
	        	$("#personMsg").form("reset");
	       		$("#imgPhoto").attr("src","images/defaultperson.gif");
		       	if(data.status != 0){
		       		$.messager.alert("系统消息",data.msg,"error");
		       		return;
		       	}
		       	if(data.corp){
		       		corpInfo = data.corp;
		       		if(corpInfo && corpInfo.lkBrchId){
						$("#lkBrchId").combotree("setValue", corpInfo.lkBrchId);
					}
		       	}
	       		if(dealNull(data.person.certNo).length > 0){
	       			imgDeal.getImgMessageByCertNo($("#certNo").val(),function(data){
	       		 		dwr.util.setValue("imgPhoto",data.imageMsg);
	       		 	});
	       			/* commonDwr.judgeBusType($("#certNo").val(),function(data){
	       				$("#busType").combobox("setValue",data["busType"]);
	       			}); */
	       		}
	       		$("#customerName2").val(dealNull(data.person.name));
	       		$("#certNo2").val(dealNull(data.person.certNo));
	       		$("#certType").val(dealNull(data.person.certTypes));
	       		$("#gender").val(dealNull(data.person.genderName));
	       		$("#resideType").val(dealNull(data.resideType));
	       		$("#mobileNo").val(dealNull(data.person.mobileNo));
	       		$("#regionId").val(dealNull(data.person.regionName));
	       		$("#townId").val(dealNull(data.person.townName));
	       		$("#commId").val(dealNull(data.person.commName));
	       		$("#corpCustomerId").val(dealNull(data.person.corpName));
	       		$("#resideAddr").val(dealNull(data.person.resideAddr));
	       		$("#applyFlag").val(data.applyFlag);
	       		$("#customerId").val(data.person.customerId);
	       		$("#medState").val(data.baseSiinfo.medState == "0" ? "正常" : "不正常");
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
	function query(){
		var certNo = $("#certNo").val();
		if(dealNull(certNo) == ""){
			$.messager.alert("系统消息","请输入证件号码！","error");
			return;
		}
	    $grid.datagrid("load",{
		    queryType:"0",
			certNo:$("#certNo").val(),
			customerName:$("#customerName").val()
		});
	}
	function toApply(){
		if(dealNull($("#customerId").val()) == ""){
			$.messager.alert("系统消息","请先进行客户信息查询再进行申领！","error");
			return;
		}
		var certNo = $("#certNo2").val();
		if(dealNull(certNo) == ""){
			$.messager.alert("系统消息","证件号码不能为空,请先进行客户信息查询再进行申领！","error");
			return;
		}
		if(dealNull($("#resideType").val()) == ""){
			$.messager.alert("系统消息","户籍类型不能为空，请到客户信息管理修改该客户籍类型信息！","error");
			return;
		}
		if(dealNull($("#regionId").val()) == ""){
			$.messager.alert("系统消息","所属区域不能为空，请到客户信息管理修改该客户所属区域信息！","error");
			return;
		}
		if(dealNull($("#gender").val()) == ""){
			$.messager.alert("系统消息","性别不能为空，请到客户信息管理修改该客户性别信息！","error");
			return;
		}
		if(dealNull($("#applyFlag").val()) != ""){
			if(dealNull($("#applyFlag").val()) == "0"){
				$.messager.alert("系统消息","已存在申领记录，不能重复申领！","error");
				return;
			}
		}
		if(dealNull($("#busType").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择公交类型！","error");
			return;
		}
		if(dealNull($("#bankId").combobox("getValue")) == "" && $("#cardType").combobox("getValue") == "<%=com.erp.util.Constants.CARD_TYPE_SMZK%>"){
			$.messager.alert("系统消息","请选择银行！","error",function(){
				$("#bankId").combobox("showPanel");
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要进行申领吗？",function(r){
			if(r){
				$.messager.progress({text:"正在进行申领，请稍后...."});
				$.post("cardapply/cardApplyAction!saveOneCardApply.action", { 
				    "apply.busType":$("#busType").combobox("getValue"),
				    "apply.isUrgent":$("#isUrgent").combobox("getValue"),
				    costFee:$("#costFee").combobox("getValue"),
				    urgentFee:$("#urgentFee").combobox("getValue"),
				    bankId:$("#bankId").combobox("getValue"),
				    agtCertType:$("#agtCertType").combobox("getValue"),
				    agtCertNo:$("#agtCertNo").val(),
				    agtName:$("#agtName").val(),
				    agtTelNo:$("#agtTelNo").val(),
				    customerName:$("#customerName").val(),
				    customerId:$("#customerId").val(),
				    "apply.cardType":$("#cardType").combobox("getValue"),
				    "rec.dealState":$("#dealState").combobox("getValue"),
				    "apply.recvBrchId":$("#lkBrchId").combobox("getValue")
				},function(data){
					$.messager.progress("close");
			     	if(data.status == "0"){
			     		$.messager.alert("系统消息","申领保存成功","info",function(){
			     			showReport("个人卡片申领",data.dealNo);
			     			$grid.datagrid("reload");
			     			$("#agtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
			     			$("#agtCertNo").val("");
			     			$("#agtName").val("");
			     			$("#agtTelNo").val("");
			     			$("#bankId").combobox("setValue","");
			     		});
			     	}else{
			     		$.messager.alert("系统消息",data.msg,"error");
			     	}
			},"json");
			}
		});
	}
	function readIdCard(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#certNo").val(certinfo["cert_No"]);
			$("#customerName").val(certinfo["name"]);
			query();
		}
	}
	function readIdCard2(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#agtCertNo").val(certinfo["cert_No"]);
			$("#agtName").val(certinfo["name"]);
		}
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
	function photoUpload() {
		if(dealNull($("#customerId").val()) == "") {
			$.messager.alert("系统消息","请先查询要修改照片的客户信息！","error");
			return;
		}
		$.modalDialog({
			title:"照片选择导入",
			width:800,
			height:350,
			resizable:false,
			href:"jsp/photoImport/photoSignImportView.jsp",
			onLoad:function(){
				var f = $.modalDialog.handler.find("#form");
				f.form("load", {"personPhotoId": $("#customerId").val()});
			},
  			buttons:[{
				text:"保存",
				iconCls:"icon-ok",
				handler:function() {
					fileUpload();
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
				}
			}]
		});
	}
	if("<%=com.erp.util.Constants.ENTER_TO_QUERY%>" == "0"){
		$(document).keypress(function(e){
			if(e.keyCode == 13){
				query();
			}
		});
	}
	function photoProcessUpload() {
		var customerId = $("#customerId").val();
		if (customerId) {
			$.modalDialog({
				title: "照片处理导入",
				width: 850,
				height: 550,
				resizable: false,
				href: "jsp/photoImport/photoProcessUploadView.jsp",
				onLoad: function() {
					var f = $.modalDialog.handler.find("#form");
					f.form("load", {
						"customerId": rows[0].CUSTOMER_ID
					});
				},
				buttons:[
				    {
						text: "保存",
						iconCls: "icon-ok",
						handler: function() {
							photoProcessDataUpload();
						}
					}, 
					{
						text: "取消",
						iconCls: "icon-cancel",
						handler: function() {
							$.modalDialog.handler.dialog("destroy");
							$.modalDialog.handler = undefined;
						}
					}
				]
			});
		} else {
			$.messager.alert("系统消息", "人员信息为空！", "error");
		}
	}

</script>
<n:initpage title="人员进行申领操作！<span style='color:red;'>特别提醒：</span>申领保存时，请根据实际情况选择公交类型。">
	<n:center layoutOptions="fit:false,border:true" cssStyle="height:130px;">
		<div id="tb">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="certNo" class="textinput" id="certNo" type="text" maxlength="18"/></td>
					<td class="tableleft">客户姓名：</td>
					<td class="tableright"><input name="customerName" class="textinput" id="customerName" type="text" maxlength="30"/></td>
					<td style="padding-left:2px">
						<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
						<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="人员申领信息" style="width:100%"></table>
	</n:center>
	<div data-options="region:'south',border:true,fit:false" style="height:350px;width:auto;overflow-y:hidden;overflow-x:hidden;border-bottom:none;border-left:none;">
		<div class="datagrid-toolbar" style="height:100%">
			<form id="personMsg">
				<input name="applyFlag" id="applyFlag" type="hidden"/>
				<input name="customerId" id="customerId" type="hidden"/>
		        <h3 class="subtitle">个人基本信息</h3>
				<table class="tablegrid" style="border-bottom:none;">
					<tr>
					    <th class="tableleft" style="width:10%">客户姓名：</th>
						<td class="tableright" style="width:19%"><input id="customerName2" name="bp.name" type="text" class="textinput" readonly="readonly"/></td>
						<th class="tableleft" style="width:10%">证件号码：</th>
						<td class="tableright" style="width:19%"><input id="certNo2" name="bp.certNo" type="text" class="textinput" readonly="readonly"/></td>
						<th class="tableleft" style="width:10%">证件类型：</th>
						<td class="tableright" style="width:19%"><input id="certType" name="bp.certType" type="text" class="textinput" readonly="readonly"/></td>
					    <td rowspan="6" style="vertical-align:top;text-align:center;">
							<img id="imgPhoto" style="width:120px;height:160px;vertical-align:top;" src="images/defaultperson.gif" alt=""/>
							<br/>
							<a href="javascript:void(0);" class="easyui-linkbutton" style="margin-top:5px;" iconCls="icon-edit"  plain="false" onclick="photoProcessUpload();">修改照片</a>
						</td>
					</tr>
					<tr>
					 	<th class="tableleft">性别：</th>
						<td class="tableright"><input id="gender" name="bp.gender" type="text" class="textinput" readonly="readonly"/></td>
					 	<th class="tableleft">户籍类型：</th>
						<td class="tableright"><input id="resideType" name="bp.resideType" class="textinput" readonly="readonly"/></td>
						<th class="tableleft">手机号码：</th>
						<td class="tableright"><input id="mobileNo" name="bp.mobileNo" type="text" class="textinput" readonly="readonly"/></td> 
					</tr>
					<tr>
					    <th class="tableleft">所属区域：</th>
						<td class="tableright"><input id="regionId" name="bp.regionId" class="textinput" type="text" readonly="readonly"/></td>
						<th class="tableleft">乡镇（街道）：</th>
						<td class="tableright"><input id="townId" name="bp.townId" class="textinput" type="text" readonly="readonly"/></td>
						<th class="tableleft">社区（村）：</th>
						<td class="tableright"><input id="commId" name="bp.commId" class="textinput"  type="text" readonly="readonly"/></td>
					</tr>
					<tr>
						<th class="tableleft">居住地址：</th>
						<td class="tableright" colspan="3"><input id="resideAddr" name="bp.resideAddr" type="text" class="textinput" style="width:515px;" readonly="readonly"/></td>
						<th class="tableleft">单位名称：</th>
						<td class="tableright"><input id="corpCustomerId" name="bp.corpCustomerId" type="text" class="textinput" readonly="readonly"/></td>
					</tr>
					<tr>
						<th class="tableleft">医保状态：</th>
						<td class="tableright"><input id="medState" name="medState" type="text" class="textinput" readonly="readonly" /></td>
						<th class="tableleft">公交类型：</th>
						<td class="tableright"><input  id="busType" name="busType" type="text"  class="textinput" value="01"/></td>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="textinput" name="apply.cardType"/></td>
					</tr>
					<tr>
						<th class="tableleft">银行名称：</th>
						<td class="tableright"><input id="bankId" name="bankId" type="text" class="textinput easyui-validatebox" /></td>
						<th class="tableleft">制卡方式：</th>
						<td class="tableright"><input id="isUrgent" name="isUrgent" class="textinput" value="0" type="text"/></td>
						<th class="tableleft">领卡网点：</th>
						<td class="tableright">
							<input id="lkBrchId" name="lkBrchId" type="text" class="textinput">
						</td>
					</tr>
					<tr>
					    <th class="tableleft">工本费：</th>
					    <td class="tableright" ><input id="costFee" name="costFee" type="text" class="textinput" readonly="readonly"/></td>
						<th class="tableleft">加急费：</th>
						<td class="tableright" colspan="1"><input id="urgentFee" name="urgentFee" type="text" class="textinput" readonly="readonly"/></td>
						<th class="tableleft">是否判断医保状态：</th>
						<td class="tableright" colspan="2">
							<input id="dealState" name="rec.dealState" type="text" class="textinput">
						</td>
					</tr>
					<tr>
						<td colspan="7" >
							<h3 class="subtitle" style="border:none;">代理人信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright" ><input id="agtName" name="agtName" type="text" class="textinput" maxlength="30"/></td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright" ><input id="agtCertType" name="agtCertType" type="text" class="textinput"/></td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright" colspan="2"><input id="agtCertNo" name="agtCertNo" type="text" class="textinput easyui-validatebox" maxlength="18" validtype="idcard"/></td>
					</tr>
					<tr>
						<th class="tableleft">代理人联系电话：</th>
						<td class="tableright" ><input id="agtTelNo" name="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
						<td colspan="4" class="tableright" style="padding-left: 20px">
							<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<shiro:hasPermission name="onecardApplySave">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toApply();">确认申领</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</div>
</n:initpage>