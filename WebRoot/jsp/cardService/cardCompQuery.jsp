<%@page import="com.erp.util.Constants"%>
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
    <title>综合信息查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dgcardinfo;
	var $temp;
	var $gridcardinfo;
	var $dgaccountinfo;
	var $gridaccountinfo;
	var $personinfoksl;
	var $cardconsumedg;
	var tempCardNo;
	var tempCertNo;
	var params = {};
	var $servRecInfo;
	var $bankInfo;
	var $cardAppBindInfo;
	
	var tempTitle;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({
			id:"accKind",
			codeType:"ACC_KIND"
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE"
		});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
		});
	    tab_option = $("#tt").tabs("getTab","首页").panel("options").tab;  
	    tab_option.hide();
	    
	    var myDate = new Date();
		var endDate = myDate.format("yyyy-MM-dd");
		myDate.addDays(-7);
		var beginDate = myDate.format("yyyy-MM-dd");
		$("#beginTimecon").val(beginDate);
	    $("#endTimecon").val(endDate);
	    
	    $("#tt").tabs({
	        border:false,
            onSelect:function(title){
            	var certNoTemp;
            	var cardNoTemp;
            	var rows = $dgcardinfo.datagrid("getSelections");
            	if(!(rows && rows.length == 1)){
            		$.messager.alert("提示信息","<font color=\"red\">请选择卡信息！</font>","info");
       				$("#tt").tabs("select",title).tabs("select");
       				$("#tt").tabs("unselect",title);
       				return;
            	}else{
            		tempCertNo = rows[0].CERT_NO;
            		certNoTemp = rows[0].CERT_NO;
            		tempCardNo = rows[0].CARD_NO;
       				cardNoTemp = rows[0].CARD_NO;
            	}
            	if(title!="首页"){
            		if(title == "个人基本信息"){
            			$.messager.progress({title : "提示",text : "数据处理中，请稍后...."});
            			$.post("queryService/personBaseAllQueryAction!querBaseMxInfo.action",{"certNo":certNoTemp,"cardNo":cardNoTemp},function(data){
         					$.messager.progress("close");
           					var personview =  $.parseJSON(data.personview);
           					$("#personname").html(personview.name);
           					$("#certNos").html(personview.certNo);
           					$("#certTypes").html(personview.certTypes);
           					$("#pinying").html(personview.pinying);
           					$("#birthday").html(personview.birthday);
           					$("#genderName").html(personview.genderName);
           					$("#nations").html(personview.nations);
           					$("#educations").html(personview.educations);
           					$("#marrStateName").html(personview.marrStateName);
           					$("#resideTypeName").html(personview.resideTypeName);
           					$("#phoneNo").html(personview.phoneNo);
           					$("#mobileNo").html(personview.mobileNo);
           					$("#regionName").html(personview.regionName);
           					$("#townName").html(personview.townName);
           					$("#commName").html(personview.commName);
           					$("#career").html(personview.career);
           					$("#corpCustomerId").html(personview.corpCustomerId);
           					$("#customerStates").html(personview.customerStates);
           					$("#email").html(personview.email);
           					$("#postCode").html(personview.postCode);
           					$("#sureFlags").html(personview.sureFlags);
           					$("#resideAddr").html(personview.resideAddr);
           					$("#letterAddr").html(personview.letterAddr);
           					$("#note").html(personview.note);
           				},"json");
            		}else if(title == "申领信息"){
            			$personinfoksl = $("#personinfoksl"); 
            			$personinfoksl.datagrid({
            				url : "cardapply/cardApplyAction!toSearchApplyMsg.action",
            				queryParams:{queryType:"0","bp.certNo":certNoTemp,beginTime:$("#kslbeginTime").val(),endTime:$("#kslendTime").val()},
            				fit:true,
            				//scrollbarSize:0,
            				pagination:true,
            				//rownumbers:true,
            				border:false,
            				striped:true,
            				singleSelect:true,
            				//fitColumns:true,
            				pageList:[10,20,30,40,50],
            				pageSize:20,
            				frozenColumns:[[
           						{field:"V_V"},
           						{field:"APPLY_ID",title:"申领编号",sortable:true,width:parseInt($(this).width() * 0.05)},
           						{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width() * 0.04)},
           						{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.07)},
           						{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
           						{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.05)},
           						{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"GENDER",title:"性别",sortable:true,width:parseInt($(this).width() * 0.03)},
            				]],
            				columns:[[
           						{field:"APPLY_WAY",title:"申领方式",sortable:true,width:parseInt($(this).width() * 0.06), formatter:function(value){
           							if(value==<%=Constants.APPLY_WAY_LX%>){
           								return "零星申领";
           							} else if(value==<%=Constants.APPLY_WAY_DW%>){
           								return "单位申领";
           							} else if(value==<%=Constants.APPLY_WAY_SQ%>){
           								return "社区申领";
           							} else if(value==<%=Constants.APPLY_WAY_XX%>){
           								return "学校申领";
           							}
           						}},
           						{field:"APPLY_TYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.06), formatter:function(value){
           							if(value==<%=Constants.APPLY_TYPE_CCSL%>){
           								return "初次申领";
           							} else if(value==<%=Constants.APPLY_TYPE_HK%>){
           								return "换卡申领";
           							} else if(value==<%=Constants.APPLY_TYPE_BK%>){
           								return "补卡申领";
           							}
           						}},
           						{field:"APPLYDATE",title:"申领时间",sortable:true,width:parseInt($(this).width() * 0.11)},
           						{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)},
           						{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13)},
           						{field:"APPLY_STATE",title:"申领状态",sortable:true,width:parseInt($(this).width() * 0.08), formatter:function(value){
           							if(value==<%=Constants.APPLY_STATE_RWYSC%>){
           								return "任务已生成";
           							} else if(value==<%=Constants.APPLY_STATE_YFBANK%>){
           								return "已发银行审核";
           							} else if(value==<%=Constants.APPLY_STATE_YFF%>){
           								return "已发放";
           							} else if(value==<%=Constants.APPLY_STATE_YSQ%>){
           								return "已申领";
           							} else if(value==<%=Constants.APPLY_STATE_YHSHBTG%>){
           								return "银行审核不通过";
           							} else if(value==<%=Constants.APPLY_STATE_YHSHTG%>){
           								return "银行审核通过";
           							} else if(value==<%=Constants.APPLY_STATE_ZKZ%>){
           								return "制卡中";
           							} else if(value==<%=Constants.APPLY_STATE_YZK%>){
           								return "已制卡";
           							} else if(value==<%=Constants.APPLY_STATE_YHKHZ%>){
           								return "银行开户中";
           							} else if(value==<%=Constants.APPLY_STATE_YHKHSB%>){
           								return "银行开户失败";
           							} else if(value==<%=Constants.APPLY_STATE_YHKHCG%>){
           								return "银行开户成功";
           							} else if(value==<%=Constants.APPLY_STATE_YPS%>){
           								return "已配送";
           							} else if(value==<%=Constants.APPLY_STATE_YJS%>){
           								return "已接收";
           							} else if(value==<%=Constants.APPLY_STATE_YTK%>){
           								return "已退卡";
           							} else if(value==<%=Constants.APPLY_STATE_YHS%>){
           								return "已回收";
           							} else if(value==<%=Constants.APPLY_STATE_YZX%>){
           								return "已注销";
           							}
           						}},
           						{field:"AGTCERTTYPE",title:"申领代理人证件类型",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_CERT_NO",title:"申领代理人证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_NAME",title:"申领代理人姓名",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"AGT_PHONE",title:"申领代理人联系电话",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"FULL_NAME",title:"办理网点",sortable:true,width:parseInt($(this).width() * 0.08)},
           						{field:"USERNAME",title:"办理柜员",sortable:true,width:parseInt($(this).width() * 0.08)},
           						{field:"REGION_NAME",title:"所属区域",sortable:true,width:parseInt($(this).width() * 0.06)},
           						{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
           							return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
           						}},
           						{field:"COMM_NAME",title:"社区（村）",sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
           							return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
           						}},
           						{field:"CORP_NAME",title:"单位",sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
           							return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
           						}}
           					]],
            				toolbar:"#cc",
            			 	onLoadSuccess:function(data){
            			 		if(dealNull(data.errMsg).length > 0){
            			 			$.messager.alert("系统消息",data.errMsg,"error");
            			 		}
            			 		var allch = $(":checkbox").get(0);
            			 		if(allch){
            			 			allch.checked = false;
            			 		}
            			 	}
            			});
	            	}else if(title == "交易信息"){
            			//查询卡交易信息
            			var beginTime = $("#beginTimecon").val();
	        		    var endTime = $("#endTimecon").val();
            			$cardconsumedg = $("#cardconsumedg");
            			$cardconsumedg.datagrid({
            				url : "statistical/statisticalAnalysisAction!rechargeAndConsumeStatistics.action",
            				queryParams:{queryType:"0",cardNo:cardNoTemp,beginTime:beginTime,endTime:endTime},
            				fit:true,
            				pagination:true,
            				rownumbers:true,
            				border:false,
            				striped:true,
            				pageSize:20,
            				singleSelect:true,
            				autoRowHeight:true,
            				scrollbarSize:0,
            				showFooter: true,
            				frozenColumns:[[
            								{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.08)},
            								{field:"DEAL_BATCH_NO",title:"批次号",sortable:true,width:parseInt($(this).width()*0.07)},
            								{field:"FULL_NAME",title:"网点/商户名称",sortable:true,width:parseInt($(this).width()*0.08)},
                       						{field:"CARD_BAL",title:"交易前金额",sortable:true,width:parseInt($(this).width()*0.06),formatter:function(value,row,index){
                       							if(!value){
                       								return "";
                       							}
                       							
                       							return $.foramtMoney(Number(value).div100());
                       						}},
                       						{field:"AMT",title:"交易金额",sortable:true,width:parseInt($(this).width()*0.06),formatter:function(value,row,index){
                       							return $.foramtMoney(Number(value).div100());
                       						}},
                       						{field:"DEAL_DATE",title:"交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
            								{field:"DEAL_CODE",title:"业务名称",sortable:true,width:parseInt($(this).width()*0.1)}
               	            			]],
                        				columns:[[
            								{field:"CUSTOMER_ID",title:"客户编号",sortable:true,minWidth:parseInt($(this).width()*0.08)},
            								{field:"ACC_NAME",title:"客户姓名",sortable:true,minWidth:parseInt($(this).width()*0.05)},
            								{field:"GENDER",title:"性别",sortable:true,minWidth:parseInt($(this).width()*0.04)},
            								{field:"CERT_TYPE",title:"证件类型",sortable:true,minWidth:parseInt($(this).width()*0.05)},
            								{field:"CERT_NO",title:"证件号码",sortable:true,minWidth:parseInt($(this).width()*0.15)},
            								{field:"CARD_TYPE",title:"卡类型",sortable:true,minWidth:parseInt($(this).width()*0.05)},
            								{field:"CARD_NO",title:"卡号",sortable:true,minWidth:parseInt($(this).width()*0.13)},
                       						{field:"ACC_NO",title:"账户号",sortable:true,minWidth:parseInt($(this).width()*0.04)},
                       						{field:"ACC_KIND",title:"账户类型",sortable:true,minWidth:parseInt($(this).width()*0.04)},
                       						{field:"END_DEAL_NO",title:"终端交易流水",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"CARD_COUNTER",title:"卡交易序列号",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"NAME",title:"柜员/终端",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"CLR_DATE",title:"清分日期",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"DEAL_STATE",title:"状态",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"NOTE",title:"备注",sortable:true,minWidth:parseInt($(this).width()*0.1)}
                       					]],
            				toolbar:"#dd",
            	            onLoadSuccess:function(data){
           	            	  	if(data.status != 0){
           	            			$.messager.alert("系统消息",data.errMsg,"error");
           	            	    }
           	            	 	var rows = data.rows;
         			 			var num = 0;
         			 			var amt = 0;
         			 			for(var i in rows){
         			 				num++;
         			 				amt += Number(rows[i].AMT);
         			 			}
         			 			var footer = [{DEAL_NO:"本地信息统计:", DEAL_BATCH_NO: num + "笔", AMT:amt}];
         			 			$cardconsumedg.datagrid("reloadFooter", footer);
            	            }
            			});
            		}else if(title == "业务信息"){
            			//查询卡业务信息
            			$servRecInfo = $("#servRecInfo");
            			$servRecInfo.datagrid({
            				url : "queryService/personBaseAllQueryAction!querservRecInfo.action",
            				queryParams:{queryType:"0",cardNo:cardNoTemp,certNo:certNoTemp},
            				fit:true,
            				pagination:true,
            				rownumbers:true,
            				border:false,
            				striped:true,
            				pageSize:20,
            				singleSelect:true,
            				scrollbarSize:0,
            				autoRowHeight:true,
            				scrollbarSize:0,
            				showFooter: true,
            				columns:[[
           						{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.05)},
           						{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.05)},
           						{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"BRCH_NAME",title:"办理网点",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"USER_NAME",title:"办理柜员",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"DEAL_CODE_NAME",title:"办理业务",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"DEAL_TIME",title:"办理时间",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"AGT_CERT_TYPE",title:"代理人证件类型",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_CERT_NO",title:"代理人证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_NAME",title:"代理人姓名",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"AGT_TEL_NO",title:"代理人联系方式",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"DEAL_AMT",title:"发生金额",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"DEAL_STATE",title:"业务状态",sortable:true,width:parseInt($(this).width()*0.05)},
           						{field:"NOTE",title:"备注",sortable:true,width:parseInt($(this).width()*0.11)}
           					]],
            				toolbar:"#ee",
            	            onLoadSuccess:function(data){
            	            	if(data.status != 0){
            	            		$.messager.alert("系统消息",data.errMsg,"error");
            	            	}
            	            }
            			});
            		}else if(title == "银行信息") {
            			//查询银行信息
            			$.messager.progress({title : "提示",text : "数据处理中，请稍后...."});
            			$.post("queryService/personBaseAllQueryAction!queryBankInfo.action",
           					{"certNo":certNoTemp,"cardNo":cardNoTemp},
           					function(data){
           						$.messager.progress("close");
            					$("#cardNo2").html(data.cardNo);
            					$("#name2").html(data.name);
            					$("#certNo2").html(data.certNo);
            					$("#bankCardNo").html(data.bankCardNo);
            					$("#bankName").html(data.bankName);
            					if(data.bankCardNo){
	            					$("#bindState").html(data.bindState == "01"?"已激活":"未激活");
	            					$("#qcWay").html(data.qcWay);
            					}
           					}
           				,"json");
	            	}else if(title == "应用开通信息") {
	            		$cardAppBindInfo = $("#cardAppBindInfo");
            			$cardAppBindInfo.datagrid({
            				url : "zxcApp/ZxcAppAction!queryAllAppBind.action",
            				queryParams:{queryType:"0",cardNo:cardNoTemp},
            				fit:true,
            				pagination:true,
            				rownumbers:true,
            				border:false,
            				striped:true,
            				pageSize:20,
            				singleSelect:true,
            				scrollbarSize:0,
            				autoRowHeight:true,
            				scrollbarSize:0,
            				showFooter: true,
            				columns:[[
           						{field:"DEAL_NO",title:"id",sortable:true,checkbox:true},
								{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:"NAME",title:"姓名",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"SEX",title:"性别",sortable:true,width : parseInt($(this).width() * 0.05)},
								{field:"CERTTYPE",title:"证件类型",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:"BINDTYPE",title:"应用类型",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"BINDDATE",title:"开通日期",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"FULL_NAME",title:"网点",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"OPERNAME",title:"柜员",sortable:true,width : parseInt($(this).width() * 0.08)}
           					]],
            				toolbar:"#ff",
            	            onLoadSuccess:function(data){
            	            	if(data.status != 0){
            	            		$.messager.alert("系统消息",data.errMsg,"error");
            	            	}
            	            }
            			});
	            	}
            		
            		tempTitle = title;
	           	}
	        }
        });
		$dgcardinfo = $("#dgcardinfo");
		$gridcardinfo = $dgcardinfo.datagrid({
			url : "queryService/personBaseAllQueryAction!querCardInfo.action",
			fit:true,
			pagination:false,
			rownumbers:false,
			border:false,
			striped:true,
			idField:"CUSTOMER_ID",
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
		        	{field:"V_V",title:""},
		        	{field:"CUSTOMER_ID",title:"",sortable:true,checkbox:true},
		        	{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.04)},
		        	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.09)},
		        	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.03)},
		        	{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.04)},
		        	{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13),fixed:true},
		        	{field:"SUB_CARD_NO",title:"社保卡号",sortable:true,width : parseInt($(this).width() * 0.05)},
		        	{field:"CARDSTATE",title:"卡状态",sortable:true,width:parseInt($(this).width() * 0.03)}
			    ]],
              onLoadSuccess:function(data){
            	if(data.status != 0){
            		$.messager.alert("系统消息",data.errMsg,"error");
            	}
            	
				$("#dgcardinfo").datagrid("clearSelections");
            	
   				$("#tt").tabs("unselect",tempTitle);
            },
            onSelect:function(index,row){
            	certNoTemp = row.CERT_NO;
   				cardNoTemp = row.CARD_NO;
   				var current_tab = $('#tt').tabs('getSelected');  
   				var title = $('.tabs-selected').text();
   				if(title!="首页"){
            		if(title == "个人基本信息"){
            			$.messager.progress({title : "提示",text : "数据处理中，请稍后...."});
            			$.post("queryService/personBaseAllQueryAction!querBaseMxInfo.action",{"certNo":certNoTemp,"cardNo":cardNoTemp},function(data){
         					$.messager.progress("close");
           					var personview =  $.parseJSON(data.personview);
           					$("#personname").html(personview.name);
           					$("#certNos").html(personview.certNo);
           					$("#certTypes").html(personview.certTypes);
           					$("#pinying").html(personview.pinying);
           					$("#birthday").html(personview.birthday);
           					$("#genderName").html(personview.genderName);
           					$("#nations").html(personview.nations);
           					$("#educations").html(personview.educations);
           					$("#marrStateName").html(personview.marrStateName);
           					$("#resideTypeName").html(personview.resideTypeName);
           					$("#phoneNo").html(personview.phoneNo);
           					$("#mobileNo").html(personview.mobileNo);
           					$("#regionName").html(personview.regionName);
           					$("#townName").html(personview.townName);
           					$("#commName").html(personview.commName);
           					$("#career").html(personview.career);
           					$("#corpCustomerId").html(personview.corpCustomerId);
           					$("#customerStates").html(personview.customerStates);
           					$("#email").html(personview.email);
           					$("#postCode").html(personview.postCode);
           					$("#sureFlags").html(personview.sureFlags);
           					$("#resideAddr").html(personview.resideAddr);
           					$("#letterAddr").html(personview.letterAddr);
           					$("#note").html(personview.note);
           				},"json");
            		}else if(title == "申领信息"){
            			$personinfoksl = $("#personinfoksl"); 
            			$personinfoksl.datagrid({
            				url : "cardapply/cardApplyAction!toSearchApplyMsg.action",
            				queryParams:{queryType:"0","bp.certNo":certNoTemp,beginTime:$("#kslbeginTime").val(),endTime:$("#kslendTime").val()},
            				fit:true,
            				//scrollbarSize:0,
            				pagination:true,
            				//rownumbers:true,
            				border:false,
            				striped:true,
            				singleSelect:true,
            				//fitColumns:true,
            				pageList:[10,20,30,40,50],
            				pageSize:20,
            				frozenColumns:[[
           						{field:"V_V"},
           						{field:"APPLY_ID",title:"申领编号",sortable:true,width:parseInt($(this).width() * 0.05)},
           						{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width:parseInt($(this).width() * 0.04)},
           						{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.07)},
           						{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.05)},
           						{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.05)},
           						{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"GENDER",title:"性别",sortable:true,width:parseInt($(this).width() * 0.03)},
            				]],
            				columns:[[
           						{field:"APPLY_WAY",title:"申领方式",sortable:true,width:parseInt($(this).width() * 0.06)},
           						{field:"APPLY_TYPE",title:"申领类型",sortable:true,width:parseInt($(this).width() * 0.06)},
           						{field:"APPLYDATE",title:"申领时间",sortable:true,width:parseInt($(this).width() * 0.11)},
           						{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)},
           						{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13)},
           						{field:"APPLYSTATE",title:"申领状态",sortable:true,width:parseInt($(this).width() * 0.08)},
           						{field:"AGTCERTTYPE",title:"申领代理人证件类型",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_CERT_NO",title:"申领代理人证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_NAME",title:"申领代理人姓名",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"AGT_PHONE",title:"申领代理人联系电话",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"FULL_NAME",title:"办理网点",sortable:true,width:parseInt($(this).width() * 0.08)},
           						{field:"USERNAME",title:"办理柜员",sortable:true,width:parseInt($(this).width() * 0.08)},
           						{field:"REGION_NAME",title:"所属区域",sortable:true,width:parseInt($(this).width() * 0.06)},
           						{field:"TOWN_NAME",title:"乡镇（街道）",sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
           							return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
           						}},
           						{field:"COMM_NAME",title:"社区（村）",sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
           							return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
           						}},
           						{field:"CORP_NAME",title:"单位",sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
           							return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
           						}}
           					]],
            				toolbar:"#cc",
            			 	onLoadSuccess:function(data){
            			 		if(dealNull(data.errMsg).length > 0){
            			 			$.messager.alert("系统消息",data.errMsg,"error");
            			 		}
            			 		var allch = $(":checkbox").get(0);
            			 		if(allch){
            			 			allch.checked = false;
            			 		}
            			 	}
            			});
	            	}else if(title == "交易信息"){
            			//查询卡交易信息
            			var beginTime = $("#beginTimecon").val();
	        		    var endTime = $("#endTimecon").val();
            			$cardconsumedg = $("#cardconsumedg");
            			$cardconsumedg.datagrid({
            				url : "statistical/statisticalAnalysisAction!rechargeAndConsumeStatistics.action",
            				queryParams:{queryType:"0",cardNo:cardNoTemp,beginTime:beginTime,endTime:endTime},
            				fit:true,
            				pagination:true,
            				rownumbers:true,
            				border:false,
            				striped:true,
            				pageSize:20,
            				singleSelect:true,
            				autoRowHeight:true,
            				scrollbarSize:0,
            				showFooter: true,
            				frozenColumns:[[
            								{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.08)},
            								{field:"DEAL_BATCH_NO",title:"批次号",sortable:true,width:parseInt($(this).width()*0.07)},
            								{field:"FULL_NAME",title:"网点/商户名称",sortable:true,width:parseInt($(this).width()*0.08)},
                       						{field:"CARD_BAL",title:"交易前金额",sortable:true,width:parseInt($(this).width()*0.06),formatter:function(value,row,index){
                       							return $.foramtMoney(Number(value).div100());
                       						}},
                       						{field:"AMT",title:"交易金额",sortable:true,width:parseInt($(this).width()*0.06),formatter:function(value,row,index){
                       							return $.foramtMoney(Number(value).div100());
                       						}},
                       						{field:"DEAL_DATE",title:"交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
            								{field:"DEAL_CODE",title:"业务名称",sortable:true,width:parseInt($(this).width()*0.1)}
               	            			]],
                        				columns:[[
            								{field:"CUSTOMER_ID",title:"客户编号",sortable:true,minWidth:parseInt($(this).width()*0.08)},
            								{field:"ACC_NAME",title:"客户姓名",sortable:true,minWidth:parseInt($(this).width()*0.05)},
            								{field:"GENDER",title:"性别",sortable:true,minWidth:parseInt($(this).width()*0.04)},
            								{field:"CERT_TYPE",title:"证件类型",sortable:true,minWidth:parseInt($(this).width()*0.05)},
            								{field:"CERT_NO",title:"证件号码",sortable:true,minWidth:parseInt($(this).width()*0.15)},
            								{field:"CARD_TYPE",title:"卡类型",sortable:true,minWidth:parseInt($(this).width()*0.05)},
            								{field:"CARD_NO",title:"卡号",sortable:true,minWidth:parseInt($(this).width()*0.13)},
                       						{field:"ACC_NO",title:"账户号",sortable:true,minWidth:parseInt($(this).width()*0.04)},
                       						{field:"ACC_KIND",title:"账户类型",sortable:true,minWidth:parseInt($(this).width()*0.04)},
                       						{field:"END_DEAL_NO",title:"终端交易流水",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"CARD_COUNTER",title:"卡交易序列号",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"NAME",title:"柜员/终端",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"CLR_DATE",title:"清分日期",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"DEAL_STATE",title:"状态",sortable:true,minWidth:parseInt($(this).width()*0.1)},
                       						{field:"NOTE",title:"备注",sortable:true,minWidth:parseInt($(this).width()*0.1)}
                       					]],
            				toolbar:"#dd",
            	            onLoadSuccess:function(data){
           	            	  	if(data.status != 0){
           	            			$.messager.alert("系统消息",data.errMsg,"error");
           	            	    }
            	            }
            			});
            		}else if(title == "业务信息"){
            			//查询卡业务信息
            			$$cardAppBindInfo = $("#$cardAppBindInfo");
            			$servRecInfo.datagrid({
            				url : "queryService/personBaseAllQueryAction!querservRecInfo.action",
            				queryParams:{queryType:"0",cardNo:cardNoTemp,certNo:certNoTemp},
            				fit:true,
            				pagination:true,
            				rownumbers:true,
            				border:false,
            				striped:true,
            				pageSize:20,
            				singleSelect:true,
            				scrollbarSize:0,
            				autoRowHeight:true,
            				scrollbarSize:0,
            				showFooter: true,
            				columns:[[
           						{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.05)},
           						{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.05)},
           						{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"BRCH_NAME",title:"办理网点",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"USER_NAME",title:"办理柜员",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"DEAL_CODE_NAME",title:"办理业务",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"DEAL_TIME",title:"办理时间",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"AGT_CERT_TYPE",title:"代理人证件类型",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_CERT_NO",title:"代理人证件号码",sortable:true,width:parseInt($(this).width() * 0.12)},
           						{field:"AGT_NAME",title:"代理人姓名",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"AGT_TEL_NO",title:"代理人联系方式",sortable:true,width:parseInt($(this).width() * 0.10)},
           						{field:"DEAL_AMT",title:"发生金额",sortable:true,width:parseInt($(this).width()*0.1)},
           						{field:"DEAL_STATE",title:"业务状态",sortable:true,width:parseInt($(this).width()*0.05)},
           						{field:"NOTE",title:"备注",sortable:true,width:parseInt($(this).width()*0.11)}
           					]],
            				toolbar:"#ee",
            	            onLoadSuccess:function(data){
            	            	if(data.status != 0){
            	            		$.messager.alert("系统消息",data.errMsg,"error");
            	            	}
            	            }
            			});
            		}else if(title == "银行信息") {
            			//查询银行信息
            			$.messager.progress({title : "提示",text : "数据处理中，请稍后...."});
            			$.post("queryService/personBaseAllQueryAction!queryBankInfo.action",
           					{"certNo":certNoTemp,"cardNo":cardNoTemp},
           					function(data){
           						$.messager.progress("close");
            					$("#cardNo2").html(data.cardNo);
            					$("#name2").html(data.name);
            					$("#certNo2").html(data.certNo);
            					$("#bankCardNo").html(data.bankCardNo);
            					$("#bankName").html(data.bankName);
            					if(data.bankCardNo){
	            					var bindState = data.bindState == "01"?"已激活":"未激活";
	            					$("#bindState").html(bindState);
	            					$("#qcWay").html(data.qcWay);
            					}
           					}
           				,"json");
	            	} else if(title == "应用开通信息") {
            			$cardAppBindInfo = $("#cardAppBindInfo");
            			$cardAppBindInfo.datagrid({
            				url : "zxcApp/ZxcAppAction!queryAllAppBind.action",
            				queryParams:{queryType:"0",cardNo:cardNoTemp},
            				fit:true,
            				pagination:true,
            				rownumbers:true,
            				border:false,
            				striped:true,
            				pageSize:20,
            				singleSelect:true,
            				scrollbarSize:0,
            				autoRowHeight:true,
            				scrollbarSize:0,
            				showFooter: true,
            				columns:[[
           						{field:"DEAL_NO",title:"id",sortable:true,checkbox:true},
								{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:"NAME",title:"姓名",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"SEX",title:"性别",sortable:true,width : parseInt($(this).width() * 0.05)},
								{field:"CERTTYPE",title:"证件类型",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.12)},
								{field:"BINDTYPE",title:"应用类型",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"BINDDATE",title:"开通日期",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"FULL_NAME",title:"网点",sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:"OPERNAME",title:"柜员",sortable:true,width : parseInt($(this).width() * 0.08)}
           					]],
            				toolbar:"#ff",
            	            onLoadSuccess:function(data){
            	            	if(data.status != 0){
            	            		$.messager.alert("系统消息",data.errMsg,"error");
            	            	}
            	            }
            			});
	            	}
            		tempTitle = title;
	           	}
            }
		});
		$dgaccountinfo = $("#dgaccountinfo");
		$gridaccountinfo = $dgaccountinfo.datagrid({
			url : "queryService/personBaseAllQueryAction!queryAccountInfo.action",
			fit:true,
			pagination:false,
			rownumbers:false,
			border:false,
			striped:true,
			idField:"ACC_NO",
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
	        	//{field:"V_V",title:""},
	        	//{field:"ACC_NO",title:"",sortable:true,checkbox:true},
	        	{field:"ACCKIND",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.05)},
	        	//{field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.05)},
	        	//{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.09)},
	        	{field:"NAME",title:"账户名称",sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.13),fixed:true},
	        	{field:"ACCSTATE",title:"账户状态",sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:"BAL",title:"账户余额",sortable:true,width:parseInt($(this).width() * 0.05)}
	        ]],
            onLoadSuccess:function(data){
           		if(data.status != 0){
           			$.messager.alert("系统消息",data.errMsg,"error");
           	  	}
            }
		});
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,"") == "" && $("#cardNo").val().replace(/\s/g,"") == ""){
			parent.$.messager.show({
				title :"系统消息",
				msg : "请输入查询证件号码或是卡号！",
				timeout : 1000 * 2
   			});
			return;
		}
		$dgcardinfo.datagrid("load",{
			queryType:"0",//查询类型
			certNo:$("#certNo").val(), 
			cardType:$("#cardType").combobox("getValue"),
			cardNo:$("#cardNo").val()
		});
		$dgaccountinfo.datagrid("load",{
			queryType:"0",//查询类型
			certNo:$("#certNo").val(), 
			cardType:$("#cardType").combobox("getValue"),
			cardNo:$("#cardNo").val()
		});
	}
	//读卡,对卡号进行赋值,验证卡信息
	var cardinfo;
	function readCard(){
		try{
			cardinfo = getcardinfo();
			if(dealNull(cardinfo["card_No"]).length == 0){
				$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！","error");
				return;
			}else{
				tempCardNo= cardinfo["card_No"];
				tempCertNo = cardinfo["cert_No"];
				$("#cardNo").val(cardinfo["card_No"]);
				$("#certNo").val(cardinfo["cert_No"]);
			}
			query();
		}catch(e){
			errorsMsg = "";
			for (i in e) {
				errorsMsg += i + ":" + eval("e." + i) + "\n";
			}
			$.messager.alert("系统消息",errorsMsg,"error");
		}
	}
	// 读身份证
	function readIdCard(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length == 0){
			return;
		}
		tempCertNo = certinfo["cert_No"];
		$("#certNo").val(certinfo["cert_No"]);
	}
	
	//查询卡申领信息
	function queryksl(){
		$personinfoksl.datagrid("load",{
			"queryType": "0",
			"bp.certNo": tempCertNo,
			"beginTime": $("#kslbeginTime").val(),
			"endTime": $("#kslendTime").val()
		});
	}
	//查询卡交易明细
	function querycardComplexInfo(){
		//判断卡号是否为空
		var currietecardNo = "";
		var row = $dgcardinfo.datagrid("getSelected");
		currietecardNo = row.CARD_NO;
		if($("#cardNocon").val() == ""){
			$.messager.alert("系统消息","请输入查询条件！<div style=\"color:red\">提示：卡号信息</div>","warning");
			return;
		}
		$cardconsumedg.datagrid("load",{
			queryType:"0",//查询类型
			beginTime:$("#beginTimecon").val(),
		    endTime:$("#endTimecon").val(),
		    accKind:$("#accKind").combobox("getValue"),
		    cardNo:currietecardNo
		});
	}
	//查询卡业务日志信息
	function queryservRecInfo(){
		if(tempCertNo ==null||tempCertNo =="undefinded"||tempCertNo ){
			var row = $dgcardinfo.datagrid("getSelected");
			tempCertNo = row.CERT_NO;
			tempCardNo = row.CARD_NO;
		}
		$servRecInfo.datagrid("load",{
			queryType:"0",//查询类型
			beginTime:$("#beginTimeconrec").val(),
		    endTime:$("#endTimeconrec").val(),
		    certNo:tempCertNo,
		    cardNo:tempCardNo
		});
	}
	// 查询应用开通信息
	function queryCardAppBindInfo(){
		$cardAppBindInfo.datagrid("load",{
			queryType:"0",
			startDate:$("#appStartDate").val(),
		    endDate:$("#appEndDate").val(),
		    "personal.certNo":tempCertNo,
		    "personal.cardNo":tempCardNo
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	  	<div data-options="region:'north',border:false" title="" style="height:32px;overflow: hidden;">
  			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>
					在此你可以对<span class="label-info"><strong>个人卡信息、账户信息、交易信息等</strong></span>进行<span class="label-info">进行相应的查询！<span style="color:red;font-weight:600">注意：</span>查询的时候必须输入卡号或身份证！</span>
				</span>
			</div>
		</div>
		<div data-options="region:'center',border:true" style="border-left:none;border-bottom:none;margin-top:2px;">
			<div class="easyui-layout" style="width:100%;" data-options="fit:true,border:false">
				<div data-options="region:'north',border:false,collapsible:false" style="height:60px;overflow:hidden;" title="综合信息查询">
				  	<div id="tbq" style="padding:2px 0" class="datagrid-toolbar">
						<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
							<tr>
								<td class="tableleft" width="7%">证件号码：</td>
								<td class="tableright" width="18%"><input name="certNo"  class="textinput" id="certNo" type="text"/></td>
								<td class="tableleft" width="7%">卡类型：</td>
								<td class="tableright" width="18%"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" value="100" style="width:174px;"/></td>
								<td class="tableleft" width="7%">卡号：</td>
								<td class="tableright" width="18%"><input name="cardNo"  class="textinput" id="cardNo" type="text"/></td>
								<td class="tableright" width="25%" colspan="2">
									<shiro:hasPermission name="onlinerechargecanelreadcard">
										<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readCard()">读卡</a>
									</shiro:hasPermission>
									<shiro:hasPermission name="onlinerechargecanelreadidcard">
									<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readIdCard()">读身份证</a>
									</shiro:hasPermission>
									<shiro:hasPermission name="onlinerechargecanelquery">
										<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
									</shiro:hasPermission>
								</td>
							</tr>
						</table>
					</div>
				</div>
				<div data-options="region:'west',border:true" style="width:55%;">
					<table id="dgcardinfo" title="卡信息"></table>
				</div>
				<div data-options="region:'center',border:true" style="width:45%;">
					<table id="dgaccountinfo" title = "账户信息"></table>
				</div>
			</div>
		</div>
		<div data-options="region:'south'" data-options="fit:true,border:false,overflow: hidden;" style="height:60%;margin:0px;width:auto;display:black">
			<div id="tt" class="easyui-tabs" data-options="fit:true,border:false"  style="height:100%;margin:0px;width:auto">
				<div title="首页" style="width:auto; height:100%">   
			    </div> 
			    <div class="datagrid-toolbar" title="个人基本信息" style="width:auto; height:100%">
			    	<form id="form" method="post">
				    	<table class="tablegrid" style="width:100%; height:75%">
						 <tr>
						    <th class="tableleft" style="width:10%">姓名：</th>
							<td id="personname" class="tableright" style="width:20%"></td>
							<th class="tableleft" style="width:10%">证件号码：</th>
							<td id="certNos" class="tableright" style="width:20%"></td>
							<th class="tableleft" style="width:10%">证件类型：</th>
							<td id="certTypes" class="tableright" style="width:30%"></td>
						 </tr>
						 <tr>
						 	<th class="tableleft">姓名拼音：</th>
							<td id="pinying" class="tableright" colspan="1"></td>
						    <th class="tableleft">生日：</th>
							<td id="birthday" class="tableright"></td>
							<th class="tableleft">性别：</th>
							<td id="genderName" class="tableright"></td>
						 </tr>
						 <tr>
						 	<th class="tableleft">民族：</th>
							<td id="nations" class="tableright"></td>
						 	<th class="tableleft">文化程度：</th>
						 	<td id="educations" class="tableright"></td>
							<th class="tableleft">婚姻状况：</th>
						    <td id="marrStateName" class="tableright"></td>
						 </tr>
						 <tr>
						 	<th class="tableleft">户籍类型：</th>
							<td id="resideTypeName" class="tableright"></td>
							<th class="tableleft">固定电话：</th>
							<td id="phoneNo" class="tableright"></td>
							<th class="tableleft">手机号码：</th>
							<td id="mobileNo" class="tableright"></td> 
							
						 </tr>
						 <tr>
						    <th class="tableleft">所属区域：</th>
							<td id="regionName" class="tableright"></td>
							<th class="tableleft">乡镇（街道）：</th>
							<td id="townName" class="tableright"></td>
							<th class="tableleft">社区（村）：</th>
							<td id="commName" class="tableright"></td>
						 </tr>
						<tr>
							<th class="tableleft">职业：</th>
							<td id="career" class="tableright"></td>
							<th class="tableleft">单位编号：</th>
							<td id="corpCustomerId" class="tableright"></td>
							<th class="tableleft">客户状态：</th>
							<td id="customerStates" class="tableright" colspan="1"></td>
						</tr>
						<tr>
							<th class="tableleft">邮箱：</th>
							<td id="email" class="tableright"></td>
							<th class="tableleft">邮政编码：</th>
							<td id="postCode" class="tableright" colspan="1"></td>
							<th class="tableleft">是否确认：</th>
							<td id="sureFlags" class="tableright" colspan="1"></td>
						</tr>
						<tr>
							<th class="tableleft">居住地址：</th>
							<td id="resideAddr" class="tableright" colspan="5"></td>
						</tr>
						<tr>
							<th class="tableleft">联系地址：</th>
							<td id="letterAddr" class="tableright" colspan="5"></td>
						</tr>
						<tr>
							<th class="tableleft">备注：</th>
							<td id="note" class="tableright" colspan="5"></td>
						</tr>
					 </table>
				   </form>
			    </div>	
				<div class="datagrid-toolbar" title="申领信息">
					<table id="cc"  cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
						<tr>
							<td class="tableleft" style="width:8%" >申领起始时间：</td>
							<td class="tableright" style="width:15%"><input name="beginTime"  class="Wdate textinput" id="kslbeginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
							<td class="tableleft" style="width:8%">申领截至时间：</td>
							<td class="tableright" style="width:15%"><input name="endTime"  class="Wdate textinput" id="kslendTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
							<td class="tableright">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="queryksl()">查询</a>
							</td>
						</tr>
					</table>   
					<table id="personinfoksl"></table>
			    </div>   
			    <div class="datagrid-toolbar" title="交易信息">
			    	<table id="dd" cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
						<tr>
							<td class="tableleft">起始日期：</td>
							<td class="tableright"><input  id="beginTimecon" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
							<td class="tableleft">结束日期：</td>
							<td class="tableright"><input id="endTimecon" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
							<td class="tableleft">账户类型：</td>
							<td class="tableright"><input id="accKind" type="text" class="easyui-combobox" name="accKind" value="02"/></td>
							<td class="tableleft">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton1" name="subbutton1" onclick="querycardComplexInfo()">查询</a>
							</td>
						</tr>
					</table>
					<table id="cardconsumedg"></table>   
			    </div>   
			    <div class="datagrid-toolbar" title="业务信息"> 
			        <table id="ee" cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
						<tr>
							<td class="tableleft" style="width:8%">起始日期：</td>
							<td class="tableright" style="width:15%"><input  id="beginTimeconrec" type="text" name="beginTimecon" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
							<td class="tableleft" style="width:8%">结束日期：</td>
							<td class="tableright" style="width:15%"><input id="endTimeconrec type="text"  name="endTimecon" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
							<td class="tableright">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton1" name="subbutton1" onclick="queryservRecInfo()">查询</a>
							</td>
						</tr>
					</table> 
					<table id="servRecInfo"></table> 
			    </div> 
			    <div class="datagrid-toolbar" title="银行信息" style="width:auto; height:100%">
			    	<form id="form" method="post">
				    	<table class="tablegrid" style="width:100%; height:75%">
						 <tr>
						 	<th class="tableleft" style="width:10%">姓名：</th>
							<td id="name2" class="tableright" style="width:23%"></td>
						    <th class="tableleft" style="width:10%">身份证：</th>
							<td id="certNo2" class="tableright" style="width:23%"></td>
						    <th class="tableleft" style="width:10%">卡号：</th>
							<td id="cardNo2" class="tableright" style="width:23%"></td>
						 </tr>
						 <tr>
						 	<th class="tableleft" style="width:10%">银行账号：</th>
							<td id="bankCardNo" class="tableright" style="width:23%"></td>
							<th class="tableleft" style="width:10%">银行：</th>
							<td id="bankName" class="tableright" style="width:23%"></td>
							<td class="tableleft" style="width:10%">激活状态</td>
							<td id="bindState" class="tableright" style="width:23%"></td>
						 </tr>
						 <tr>
						 	<th class="tableleft" style="width:10%">圈存方式：</th>
							<td id="qcWay" class="tableright" colspan="5"></td>
						 </tr>
					 </table>
				   </form>
			    </div>
			    <!-- <div class="datagrid-toolbar" title="应用开通信息">
			    	<table id="ff" cellpadding="0" cellspacing="0" width="100%" class="tablegrid">
						<tr>
			    			<td class="tableleft" style="width:8%">开始日期：</td>
							<td class="tableright" style="width:15%"><input id="appStartDate" name="appStartDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
							<td class="tableleft" style="width:8%">结束日期：</td>
							<td class="tableright" style="width:15%"><input id="appEndDate" name="appEndDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
							<td class="tableright">
								<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="queryCardAppBindInfo()">查询</a>
							</td>
						</tr>
					</table>
					<table id="cardAppBindInfo"></table>
			    </div> -->
			</div>
	</div>
</body>
</html>
