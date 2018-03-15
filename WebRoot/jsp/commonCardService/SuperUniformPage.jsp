<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type='text/javascript' src='dwr/interface/imgDeal.js'></script>
<style>
	.textinput{
		width:160px;
	}
	.textinput2{
		width:150px;
	}
</style>
<script type="text/javascript">
	var corpInfo;
	var globalAgtCertTypeArr = ["personalCertType","personalInfoCertType","cardApplyInfoAgtCertType","cardIssuseInfoAgtCertType","gsAgtCertType","jsAgtCertType"];
	var globalisreadcard = "1";
	var globalcurreadcardno = "";
	var $cardInfoGrid;
	var $accInfoGrid;
	var globalCardInfo;
	$(function(){
		$.autoComplete({
			id:"queryCertNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			optimize:true
		},"queryName");
		$.autoComplete({
			id:"queryName",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			optimize:true,
			minLength:"1"
		},"queryCertNo");
		
		$("#queryCertNo").bind("keyup", function(){
			$("#querySubCardNo").val("");
			$("#queryCardNo").val("");
			$("#queryName").val("");
		});
		
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		$("#uniformPageCenter").tabs({
			onSelect:function(title, index){
				if(index == 6 && $("#bkInfoCostFee")){ // 选中补卡时刷新补卡工本费
					$("#bkInfoCostFee").combobox("select", "20.00");
				}
			}
		});
		
		createSysCode({
			id:"personalGender",
			codeType:"SEX",
			value:"0",
			width:150,
			hasDownArrow:false
		});
		$cardInfoGrid = createDataGrid({
			id:"cardinfo",
			url:"commonCardService/commonCardServiceAction!queryCommonMsg.action",
			fit:true,
			pagination:false,
			rownumbers:false,
			border:false,
			striped:true,
			scrollbarSize:0,
			singleSelect:true,
			fitColumns:true,
			columns:[[
				{field:"CARDTYPE",title:"卡类型",sortable:true},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.07)},
				{field:"CARDSTATE",title:"卡状态",sortable:true},
		    	{field:"SUB_CARD_NO",title:"社会保障卡号",sortable:true},
		    	{field:"PWDSET",title:"交易密码",sortable:true},
		    	{field:"PWDSET2",title:"服务密码",sortable:true}
		    ]],
		    onLoadSuccess:function(data){
		    	corpInfo = null;
		    	if(data.status != "0"){
		    		jAlert(data.errMsg);
		    		deteteGridAllRows("accinfo");
		    		$("#personalInfo").form("reset");
		    		$("#personalForm").form("reset");
		    	}else{
		    		if(data.personFlag == "0"){
		    			corpInfo = data.corp;
		    			<shiro:hasPermission name="supSMKOper">
			    			if(corpInfo && corpInfo.lkBrchId){
								$("#cardApplyInfoLkBrchId").combotree("setValue", corpInfo.lkBrchId);
							} else {
								$("#cardApplyInfoLkBrchId").combotree("setValue", "");
							}
		    			</shiro:hasPermission>
			    		var personalMsg = data.person;
			    		$("#personalName").val(personalMsg.name);
			    		$("#personalGender").combobox("setValue",dealNull(personalMsg.gender));
			    		$("#personalCertType").combobox("setValue",personalMsg.certType);
			    		$("#personalCertNo").val(dealNull(personalMsg.certNo));
			    		$("#personalMobileNo1").val(dealNull(personalMsg.mobileNo));
			    		$("#personalMobileNo2").val(dealNull(personalMsg.mobileNos));
			    		$("#personalInfo").form("load",personalMsg);
			    		initPersonalInfo(personalMsg);
			    		imgDeal.getImgMessageByCertNo(personalMsg.certNo,function(data){
		       		 		dwr.util.setValue("personalInfoImgPhoto",data.imageMsg);
		       		 	});
			    		if(typeof cardApplyInfoQuery != "undefined"){
				    		cardApplyInfoQuery();
			    		}
			    		if(typeof cardIssuseInfoQuery != "undefined"){
				    		cardIssuseInfoQuery();
			    		}
		    		}
		    		if(data.cardFlag != "0"){
		    			$accInfoGrid.datagrid("load", {cardNo:'0',queryType:"0"});
		    		}else{
		    			$cardInfoGrid.datagrid("selectRow",0);
		    			$accInfoGrid.datagrid("load", {cardNo:(data.rows)[0].CARD_NO,queryType:"0"});
		    		}
		    		if(data.sbInfoFlag == "0"){
		    			initSbInfo(data);
		    		}else{
		    			initSbInfo();
		    			//社保信息不存在！
		    		}
		    		createLocalDataSelect({
		    			id:"cardApplyInfoCostFee",
		    			value:data.costFee,
		    			data:[{value:data.costFee,text:data.costFee}],
		    			width:160
		    		});
		    		createLocalDataSelect({
		    			id:"cardApplyInfoUrgentFee",
		    			value:data.urgentFee,
		    			data:[{value:data.urgentFee,text:data.urgentFee}],
		    			width:160
		    		});
		    	}
		    },
		    onClickRow:function(index,data){
           	    if(data == null)return;
           	 	$accInfoGrid.datagrid("load",{cardNo:data.CARD_NO,queryType:"0"});
          	}
		});
		$accInfoGrid = createDataGrid({
			id:"accinfo",
			url:"cardService/cardServiceAction!accountQuery.action",
			fit:true,
			pagination:false,
			rownumbers:false,
			border:false,
			striped:true,
			scrollbarSize:0,
			singleSelect:true,
			fitColumns:true,
			columns:[[
				{field:"ACCKIND",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:"ACCSTATE",title:"账户状态",sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:"BAL",title:"余额",sortable:true,width:parseInt($(this).width() * 0.06)}
		    ]],
		    onLoadSuccess:function(data){
		    	if(data.status != 0){
		    		//
		    	}
		    }
		});
		$.post("commAction!findSysCodeByCodeType.action",{codeType:"CERT_TYPE"},function(data,status){
			if(status == "success"){
				if(data.status == "0"){
					var globalAgtCertTypeArrLen = globalAgtCertTypeArr.length;
					var i = 0;
					for(;i < globalAgtCertTypeArrLen;i++){
						if(dealNull(globalAgtCertTypeArr[i]) == "personalCertType"){
							$.initLocalDataSelect({
								id:globalAgtCertTypeArr[i],
								data:data.rows,
								value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>",
								width:150
							});
						}else{
							$.initLocalDataSelect({
								id:globalAgtCertTypeArr[i],
								data:data.rows,
								value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>",
								width:160
							});
						}
						
					}
				}
			}else{
				jAlert("初始化页面参数出现错误！","error",function(){
					window.history.go(0);
				});
			}
		},"json");
	});
	function queryReadIdCard(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcertinfo();
		if(dealNull(queryCertInfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#queryCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#queryName").val(dealNull(queryCertInfo["name"]));
		$("#queryCardNo").val("");
		$("#querySubCardNo").val("");
		query();
	}
	function queryReadCard(){
		clearSearchInfo();
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		globalCardInfo = getcardinfo();
		if(dealNull(globalCardInfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + globalCardInfo["errMsg"],"error");
			return;
		}
		$.messager.progress("close");
		$("#queryCertNo").val("");
		$("#queryCardNo").val(dealNull(globalCardInfo["card_No"]));
		$("#querySubCardNo").val(dealNull(globalCardInfo["sub_Card_No"]));
		query();
	}
	function query(){
		$("#personalInfoImgPhoto").attr("src", "");
		$("#uniformPageCenter").tabs("select", 0);
		clearAgtInfo();//清空代理人信息
		if(dealNull($("#queryCertNo").val()) == "" && dealNull($("#queryCardNo").val()) == "" && dealNull($("#querySubCardNo").val()) == ""){
			jAlert("请输入查询证件号码或卡号！");
			return;
		}
		var param = getformdata("queryConts");
		param["bp.name"] = $("#queryName").val();
		param["bp.certNo"] = $("#queryCertNo").val();
		param["queryType"] = "0";
		$cardInfoGrid.datagrid("load",param);
	}
	
	function clearSearchInfo(){
		$("#queryCertNo").val("");
		$("#queryName").val("");
		$("#querySubCardNo").val("");
		$("#queryCardNo").val("");
	}
	
	function clearAgtInfo(){
		$("input.agt-info").val("");
	}
</script>
<n:initpage title="柜面常用服务进行操作！">
	<n:center layoutOptions="fit:false">
		<n:layout layoutOptions="border:false">
			<div data-options="region:'north',border:false,collapsible:false" style="width:100%">
				<div style="width:100%">
					<form id="queryConts">
						<table style="width:100%" class="tablegrid datagrid-toolbar">
							<tr>
								<td class="tableleft">证件号码：</td>
								<td class="tableright"><input id="queryCertNo" name="bp.certNo" type="text" class="textinput" maxlength="18"/></td>
								<td class="tableleft">姓名：</td>
								<td class="tableright"><input id="queryName" name="bp.name" type="text" class="textinput" maxlength="30"/></td>
								<td class="tableleft">社会保障卡号：</td>
								<td class="tableright"><input id="querySubCardNo" name="card.subCardNo" class="textinput" type="text"/></td>
								<td class="tableleft">市民卡卡号：</td>
								<td class="tableright"><input id="queryCardNo" name="card.cardNo"  class="textinput" type="text" maxlength="20"/></td>
								<td class="tableright">
									<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="queryReadIdCard()">读身份证</a>
									<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="queryReadCard()">读卡</a> 
									<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
								</td>
							</tr>
						</table>
					</form>
				</div>
				<div>
					<div class="easyui-layout" style="height:130px;width:100%" data-options="border:false">   
					    <div data-options="region:'west',title:'个人信息',split:false,collapsible:false" class="datagrid-toolbar" style="width:43%;border-left:none;border-bottom:none;">
					    	<form id="personalForm">
						    	<table style="width:100%;border-bottom:none;" class="tablegrid">
									<tr>
										<td class="tableleft">姓名：</td>
										<td class="tableright"><input id="personalName" name="bp.name" class="textinput textinput2" type="text" readonly="readonly" onfocus="this.blur();"/></td>
										<td class="tableleft">性别：</td>
										<td class="tableright"><input id="personalGender" name="bp.gender"  class="textinput textinput2" type="text" readonly="readonly" onfocus="this.blur();"/></td>
									</tr>
									<tr>
										<td class="tableleft">证件类型：</td>
										<td class="tableright"><input id="personalCertType" name="bp.certType" class="textinput textinput2" type="text" readonly="readonly" onfocus="this.blur();"/></td>
										<td class="tableleft">证件号码：</td>
										<td class="tableright"><input id="personalCertNo" name="bp.certNo" class="textinput textinput2" type="text" readonly="readonly" onfocus="this.blur();"/></td>
									</tr>
									<tr>
										<td class="tableleft">手机号码1：</td>
										<td class="tableright"><input id="personalMobileNo1" name="bp.mobileNo" class="textinput textinput2" type="text" readonly="readonly" onfocus="this.blur();"/></td>
										<td class="tableleft">手机号码2：</td>
										<td class="tableright"><input id="personalMobileNo2" name="bp.mobileNos" class="textinput textinput2" type="text" readonly="readonly" onfocus="this.blur();"/></td>
									</tr>
								</table>
							</form>
					    </div>   
					    <div data-options="region:'center',title:'卡信息',split:false" style="padding:0 0px;background:#eee;border-bottom:none;">
					    	<table id="cardinfo"></table>
					    </div> 
						<div data-options="region:'east',title:'账户信息',split:false,collapsible:false" style="width:17%;border-bottom:none;">
							<table id="accinfo"></table>
						</div>   
					</div>
				</div>
			</div>
			<div data-options="region:'center'" style="border-left:none;border-bottom:none;">
				<div id="uniformPageCenter" class="easyui-tabs" data-options="border:false,justified:false,fit:true">
					<div title="客户信息" data-options="closable:false,loadingMessage:'正在加载...'" style="overflow-x:hidden" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/personalInfo.jsp" %></div>
					<div title="医保信息" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/sbInfo.jsp" %></div>
					<shiro:lacksPermission name="supSMKOper">
						<%-- <div title="申领" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/cardApplyInfoBank.jsp" %></div> --%>   
					    <div title="发放" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/cardIssuseInfoBank.jsp" %></div> 
					</shiro:lacksPermission>
				    <shiro:hasPermission name="supSMKOper">
					   <%--  <div title="申领" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/cardApplyInfo.jsp" %></div> --%>   
					    <div title="发放" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/cardIssuseInfo.jsp" %></div> 
					    <div title="挂失" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/gsAgtInfo.jsp" %></div> 
					    <div title="解挂失" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/jsAgtInfo.jsp" %></div> 
					    <!-- <div title="补卡" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar" href="commonCardService/commonCardServiceAction!bkCardIndex.action"></div> -->
					   <!--  <div title="换卡" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar" href="commonCardService/commonCardServiceAction!hkCardIndex.action"></div>  -->
					    <div title="${ACC_KIND_NAME_LJ }充值" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/onlineAccRechargeInfo.jsp"%></div> 
					    <div title="${ACC_KIND_NAME_QB }充值" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/offlineAccRechargeInfo.jsp"%></div> 
					    <div title="密码修改" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/pwdModifyInfo.jsp"%></div> 
					    <div title="密码重置" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/pwdResetInfo.jsp"%></div> 
					   <%--  <div title="统筹区域变更" data-options="closable:false,loadingMessage:'正在加载...'" class="datagrid-toolbar"><%@include file="/jsp/commonCardService/sbInfoEdit.jsp"%></div>  --%>
					</shiro:hasPermission>
				</div> 
			</div>
		</n:layout>
	</n:center>
</n:initpage>